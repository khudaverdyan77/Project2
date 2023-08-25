import re
import os
import time
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

# Function to send an email notification
def send_email(new_ip):
    sender_email = os.getenv("gevorgyanamin@gmail.com")  # Use environment variables for sensitive data
    sender_password = os.getenv("kbkxjfgxltjymdje")
    recipient_email = os.getenv("gevorgyanamin@gmail.com")

    subject = "New IP Address Detected"
    body = f"A new IP address {new_ip} was detected in IP tables."

    msg = MIMEMultipart()
    msg["From"] = sender_email
    msg["To"] = recipient_email
    msg["Subject"] = subject
    msg.attach(MIMEText(body, "plain"))

    server = smtplib.SMTP("smtp.gmail.com", 587)
    server.starttls()
    server.login(sender_email, sender_password)
    server.sendmail(sender_email, recipient_email, msg.as_string())
    server.quit()

logfile_path = "/var/log/auth.log"

ip_count = {}

def parse_log(logline):
    match = re.search(r".* (\d+\.\d+\.\d+\.\d+).*", logline)  # Improved regular expression
    if match:
        ip = match.group(1)
        if ip in ip_count:
            ip_count[ip] += 1
        else:
            ip_count[ip] = 1
            send_email(ip)

try:
    while True:
        with open(logfile_path, "r", encoding="utf-8") as logfile:
            logfile.seek(0, 2)
            for line in logfile:
                parse_log(line)
        time.sleep(60)  # Add a delay to avoid high CPU usage and frequent emails
except KeyboardInterrupt:
    print("Script terminated.")
