#!/usr/bin/env python3
import os
import mailbox
import yaml
from email import policy
from email.parser import BytesParser

# 存档目录
ARCHIVE_SRC = "/opt/mail_archive"
MD_DIR = "/opt/md_archives"
YAML_DIR = "/opt/yaml_archives"

os.makedirs(MD_DIR, exist_ok=True)
os.makedirs(YAML_DIR, exist_ok=True)

def parse_email(msg):
    return {
        "from": msg["from"],
        "to": msg["to"],
        "subject": msg["subject"],
        "date": msg["date"],
        "body": msg.get_body(preferencelist=('plain')).get_content() if msg.get_body(preferencelist=('plain')) else None,
    }

def save_as_md(email_data, filename):
    with open(filename, "w", encoding="utf-8") as md_file:
        md_file.write(f"# {email_data['subject']}\n\n")
        md_file.write(f"- **From**: {email_data['from']}\n")
        md_file.write(f"- **To**: {email_data['to']}\n")
        md_file.write(f"- **Date**: {email_data['date']}\n\n")
        md_file.write(f"---\n\n{email_data['body']}\n")

def save_as_yaml(email_data, filename):
    with open(filename, "w", encoding="utf-8") as yaml_file:
        yaml.dump(email_data, yaml_file, allow_unicode=True)

def process_archives():
    for mbox_file in os.listdir(ARCHIVE_SRC):
        if not mbox_file.endswith(".mbox"):
            continue
        mbox_path = os.path.join(ARCHIVE_SRC, mbox_file)
        with mailbox.mbox(mbox_path, factory=lambda f: BytesParser(policy=policy.default).parse(f)) as mbox:
            for i, message in enumerate(mbox):
                email_data = parse_email(message)
                base_name = f"{mbox_file.rstrip('.mbox')}_{i+1:03}"
                save_as_md(email_data, f"{MD_DIR}/{base_name}.md")
                save_as_yaml(email_data, f"{YAML_DIR}/{base_name}.yaml")

if __name__ == "__main__":
    process_archives()

