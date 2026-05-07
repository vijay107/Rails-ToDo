// Jenkins deployment pipeline that runs the Frappe-side merge gate before
// touching production. Mirrors the JiraAPI-driven pipeline you had earlier.
//
// Setup checklist:
//   - Frappe creds added in Jenkins under credential ID `frappe-api`
//   - The ngrok / public URL of Frappe is pinned in FRAPPE_HOST below
//   - The pipeline job is configured with a "String" parameter named ISSUES
//     (comma-separated list, e.g. "TP-11,TP-12") and a "Boolean" parameter
//     BLANK_DEPLOY (defaults false)
//
pipeline {
	agent any

	parameters {
		string(name: "ISSUES", defaultValue: "TP-11", description: "Comma-separated issue IDs")
		string(name: "MERGER_EMAIL", defaultValue: "", description: "Email of the user merging (must NOT be dev_poc/reviewer/approver of any of the issues)")
		booleanParam(name: "BLANK_DEPLOY", defaultValue: false, description: "Skip the RFD state check")
	}

	environment {
		FRAPPE_HOST = "https://snap-gating-overheat.ngrok-free.dev"
	}

	stages {
		stage("Validate merge gate") {
			steps {
				script {
					def issues = params.ISSUES.split(",").collect { it.trim() }.findAll { it }
					def reqJson = groovy.json.JsonOutput.toJson([
						issues: issues,
						merger: params.MERGER_EMAIL,
						blank: params.BLANK_DEPLOY,
					])

					withCredentials([usernamePassword(
						credentialsId: "frappe-api",
						usernameVariable: "FRAPPE_KEY",
						passwordVariable: "FRAPPE_SECRET",
					)]) {
						def out = sh(
							returnStdout: true,
							script: "python3 ci/frappe_api.py validate '${reqJson}'",
						).trim()
						echo "Validation response: ${out}"
						def parsed = readJSON text: out
						if (parsed.errored) {
							error "Merge gate failed: ${parsed.payload}"
						}
						env.PR_LIST = parsed.payload.join(" ")
						env.TARGET_BRANCH = parsed.target_branch
						echo "Approved PRs: ${env.PR_LIST}"
						echo "Target branch: ${env.TARGET_BRANCH}"
					}
				}
			}
		}

		stage("Comment: deploy started") {
			steps {
				postToFrappe("Deploy #${env.BUILD_NUMBER} started by ${params.MERGER_EMAIL}")
			}
		}

		stage("Run deploy") {
			steps {
				echo "==> Pretend-merging ${env.PR_LIST} into ${env.TARGET_BRANCH}"
				echo "==> Run your real merge / build / push commands here."
				// Real example:
				//   sh "git fetch origin"
				//   sh "git checkout ${env.TARGET_BRANCH}"
				//   for (pr in env.PR_LIST.split(" ")) { sh "gh pr merge ${pr} --merge" }
			}
		}
	}

	post {
		success {
			postToFrappe("Deploy #${env.BUILD_NUMBER} SUCCESS — merged ${env.PR_LIST}")
		}
		failure {
			postToFrappe("Deploy #${env.BUILD_NUMBER} FAILED at ${env.STAGE_NAME}")
		}
	}
}

void postToFrappe(String message) {
	def issues = params.ISSUES.split(",").collect { it.trim() }.findAll { it }
	withCredentials([usernamePassword(
		credentialsId: "frappe-api",
		usernameVariable: "FRAPPE_KEY",
		passwordVariable: "FRAPPE_SECRET",
	)]) {
		for (issue in issues) {
			def reqJson = groovy.json.JsonOutput.toJson([issue: issue, message: message])
			sh "python3 ci/frappe_api.py comment '${reqJson}' || true"
		}
	}
}
