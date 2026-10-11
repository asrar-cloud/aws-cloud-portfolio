# Guided troubleshooting exercise

Use an EC2 web server from project 01 or 02. Record your own observations; no deployment or incident is claimed here.

## Baseline

1. Confirm the instance is running and both EC2 status checks pass.
2. Visit the HTTP URL and record the response code with `curl -I http://PUBLIC_IP`.
3. In CloudWatch, open the dashboard and note CPUUtilization and StatusCheckFailed over the last hour. A new instance may have sparse metrics.
4. Confirm the high-CPU alarm is in `OK` or `INSUFFICIENT_DATA`; the alarm has actions disabled.

## Safe fault simulation: blocked HTTP

1. In the lab security group, temporarily remove only the inbound TCP/80 rule. Keep the AWS console open and note the original rule.
2. Retry `curl --connect-timeout 5 -I http://PUBLIC_IP`. A timeout is expected; your actual result may differ.
3. Check the instance state and status checks. If they are healthy, inspect the security group inbound rule, subnet route to the internet gateway, and Nginx service in that order.
4. Restore TCP/80 from `0.0.0.0/0` to the lab security group. Verify the page loads again.

## Record evidence yourself

Write the time, region, instance ID suffix, symptom, checks, root cause, fix, and post-fix HTTP result in your own notes. Mask public IPs if sharing screenshots. Delete any screenshots that include account IDs or personal data.

## Other common cases

| Symptom | First checks |
| --- | --- |
| HTTP timeout | Security group, public IP, internet gateway route, Nginx status |
| HTTP 502/503 | Application process and Nginx logs: `sudo journalctl -u nginx --since '15 min ago'` |
| SSH unavailable | SSH is disabled by default; use EC2 console access or configure a trusted /32 and key pair |
| CPU alarm `INSUFFICIENT_DATA` | Wait for 2 complete five-minute periods; confirm matching instance ID and region |
| Instance status check failed | Check AWS Health and EC2 system/instance status before changing the web server |
