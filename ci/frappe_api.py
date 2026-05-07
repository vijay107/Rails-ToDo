"""Drop-in replacement for the team's JiraAPI — but talks to Frappe.

Same return contracts as the original:
    get_issue(id)                         -> (errored, dict_or_msg)
    add_comment(id, msg)                  -> (errored, msg)
    validate_merge_condition_and_get_prlist(ids, merger_email, blank_deployment=False)
                                          -> (errored, pr_list_or_msg, target_branch)

Usage from Jenkins:
    api = FrappeAPI(os.environ["FRAPPE_HOST"],
                    os.environ["FRAPPE_KEY"], os.environ["FRAPPE_SECRET"])
    err, prs, target = api.validate_merge_condition_and_get_prlist(
        ["TP-11"], merger_email="alice@aknamed.com")
"""
import json
import sys

import requests


class FrappeAPI:
	def __init__(self, host: str, api_key: str, api_secret: str):
		self.host = host.rstrip("/")
		self.session = requests.Session()
		self.session.headers["Authorization"] = f"token {api_key}:{api_secret}"
		self.session.headers["Content-Type"] = "application/json"

	def _call(self, method: str, **args):
		url = f"{self.host}/api/method/{method}"
		r = self.session.post(url, data=json.dumps(args), timeout=30)
		r.raise_for_status()
		return r.json().get("message")

	def get_issue(self, issue_id: str):
		try:
			data = self._call("erpnext.jira_dev_integrations.get_issue", issue_name=issue_id)
			if not data.get("ok"):
				return True, data.get("error") or "unknown error"
			return False, data
		except Exception as e:
			return True, f"Issue:{issue_id}, fetch failed: {e}"

	def add_comment(self, issue_id: str, message: str):
		try:
			errored, msg = self._call(
				"erpnext.jira_dev_integrations.add_task_comment",
				task_name=issue_id, message=message,
			)
			return bool(errored), msg
		except Exception as e:
			return True, f"Issue:{issue_id}, comment failed: {e}"

	def validate_merge_condition_and_get_prlist(self, issue_list, merger_user_email: str, blank_deployment: bool = False):
		try:
			errored, payload, target = self._call(
				"erpnext.jira_dev_integrations.validate_merge_condition_and_get_prlist",
				task_list=list(issue_list),
				merger_user_email=merger_user_email,
				blank_deployment=int(bool(blank_deployment)),
			)
			return bool(errored), payload, target
		except Exception as e:
			return True, f"validation failed: {e}", ""


def main():
	"""CLI entry — used by the Jenkinsfile's `validate` stage so we can keep
	the pipeline thin. Reads JSON args from $1, prints JSON result, exits
	non-zero on validation failure."""
	import os
	cmd = sys.argv[1]
	payload = json.loads(sys.argv[2]) if len(sys.argv) > 2 else {}
	api = FrappeAPI(os.environ["FRAPPE_HOST"], os.environ["FRAPPE_KEY"], os.environ["FRAPPE_SECRET"])

	if cmd == "validate":
		err, prs_or_msg, target = api.validate_merge_condition_and_get_prlist(
			payload["issues"], payload["merger"], payload.get("blank", False),
		)
		out = {"errored": err, "payload": prs_or_msg, "target_branch": target}
		print(json.dumps(out))
		sys.exit(1 if err else 0)
	elif cmd == "comment":
		err, msg = api.add_comment(payload["issue"], payload["message"])
		print(json.dumps({"errored": err, "message": msg}))
		sys.exit(1 if err else 0)
	elif cmd == "get":
		err, data = api.get_issue(payload["issue"])
		print(json.dumps({"errored": err, "data": data}))
		sys.exit(1 if err else 0)
	else:
		print(f"unknown command: {cmd}", file=sys.stderr)
		sys.exit(2)


if __name__ == "__main__":
	main()
