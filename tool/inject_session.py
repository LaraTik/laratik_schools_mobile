#!/usr/bin/env python3
"""Inject a Laratik session into the dev app's SharedPreferences.

Bypasses the OAuth UI for the dev emulator. Writes a
FlutterSharedPreferences.xml that contains a valid access_token +
refresh_token for the laratik-mobile OAuth client, plus the
non-secret session metadata the SessionStore reads at boot.

Run while the dev app is force-stopped.
"""
import subprocess
import sys
import xml.etree.ElementTree as ET
from datetime import datetime, timedelta, timezone
from urllib.parse import urlencode
from urllib.request import Request, urlopen

PKG = "io.laratik.schools.dev"
BASE = "http://localhost:8000"
CLIENT = "laratik-mobile"
USERNAME = "Administrator"
PASSWORD = "admin"
ADB = r"C:\Users\moham\AppData\Local\Android\sdk\platform-tools\adb.exe"

# 1. Get an OAuth access token.
body = urlencode({
    "grant_type": "password",
    "username": USERNAME,
    "password": PASSWORD,
    "client_id": CLIENT,
    "scope": "all openid",
}).encode()
req = Request(
    f"{BASE}/api/method/frappe.integrations.oauth2.get_token",
    data=body,
    method="POST",
    headers={"Content-Type": "application/x-www-form-urlencoded"},
)
import json
with urlopen(req, timeout=20) as r:
    payload = json.loads(r.read())
access = payload["access_token"]
refresh = payload["refresh_token"]
expires_in = int(payload.get("expires_in", 3600))
scope = payload.get("scope", "all openid")
print(f"Got token: {access[:8]}…  expires_in={expires_in}s  scope={scope}")

# 2. Fetch the user's roles so /api/method/* calls succeed (the backend
#    gates some endpoints by role).
req = Request(
    f"{BASE}/api/method/frappe.client.get_user_roles",
    headers={"Authorization": f"Bearer {access}"},
)
try:
    with urlopen(req, timeout=10) as r:
        roles_data = json.loads(r.read())
    roles = roles_data.get("message", []) or []
except Exception as e:
    print(f"WARN: could not fetch user roles: {e}")
    roles = ["Administrator", "System Manager", "LS Super Admin", "LS School Admin"]
print(f"Roles: {roles}")

# 3. Build the SharedPreferences XML.
expires_at = (datetime.now(timezone.utc) + timedelta(seconds=expires_in)).isoformat()
# We need a stable installation_id; if one is already on the device,
# keep it. Pull the current XML first.
xml_path = (
    f"/data/data/{PKG}/shared_prefs/FlutterSharedPreferences.xml"
)
dump = subprocess.check_output(
    [ADB, "shell", "run-as", PKG, "cat", xml_path],
    text=True,
)
root = ET.fromstring(dump)
existing = {child.attrib["name"]: child.text for child in root if child.tag == "string"}
installation_id = existing.get("flutter.laratik.session.installation_id") or \
    f"dev-install-{int(datetime.now().timestamp())}"

# Drop any prior token entries so we don't end up with duplicates.
to_remove = {n for n in existing if n.startswith("flutter.laratik.session.")}
for child in list(root):
    if child.tag == "string" and child.attrib.get("name") in to_remove:
        root.remove(child)

# Re-add fresh values.
def add(key, value):
    el = ET.SubElement(root, "string")
    el.set("name", f"flutter.{key}")
    el.text = value

add("laratik.session.installation_id", installation_id)
add("laratik.session.access_token", access)
add("laratik.session.refresh_token", refresh)
add("laratik.session.access_token_expires_at", expires_at)
add("laratik.session.roles", ",".join(roles))
add("laratik.session.scopes", scope)
# Pin the dev student so the dashboard "Acting as" card surfaces it
# without re-walking the audience.
add("laratik.session.current_student_id", "STU-00061")
add("laratik.session.current_enrollment_id", "ENR-00002")

new_xml = ET.tostring(root, encoding="utf-8", xml_declaration=True).decode()
print("\n--- new FlutterSharedPreferences.xml ---")
print(new_xml)

# 4. Push the XML to the device. The dev app's shared_prefs dir is
#    world-readable inside run-as, but we still write via run-as so
#    the file ownership stays correct.
# Stage to a temp path on the host, then `cp` into the app's dir.
import tempfile
import os
with tempfile.NamedTemporaryFile("w", suffix=".xml", delete=False, encoding="utf-8") as f:
    f.write(new_xml)
    local_tmp = f.name
device_tmp = "/data/local/tmp/FlutterSharedPreferences.xml"
subprocess.check_call([ADB, "push", local_tmp, device_tmp])
subprocess.check_call(
    [ADB, "shell",
     "run-as", PKG,
     "cp", device_tmp, xml_path],
)
subprocess.check_call([ADB, "shell", "rm", device_tmp])
os.unlink(local_tmp)
print(f"\nWrote {xml_path}")
