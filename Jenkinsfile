// Jenkins deployment pipeline that runs the Frappe-side merge gate before
// touching production. Uses native Groovy JSON (no extra plugins required).

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
				sh "python3 -m pip install --user --quiet requests || true"
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
							script: "python3 ci/frappe_api.py validate '${reqJson}' 2>&1 | grep -E '^\\{' | tail -1",
						).trim()
						echo "Validation response: ${out}"
						def parsed = new groovy.json.JsonSlurper().parseText(out)
						if (parsed.errored) {
							error "Merge gate failed: ${parsed.payload}"
						}
						env.PR_LIST = parsed.payload.join(" ")
						env.TARGET_BRANCH = parsed.target_branch ?: ""
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
				echo "==> Pretend-merging ${env.PR_LIST} into ${env.TARGET_BRANCH ?: '(no target set)'}"
				echo "==> Plug in your real merge / build / push commands here."
				// Example:
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
