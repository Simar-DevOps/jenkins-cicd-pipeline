# Contributing

- **Branching:** `feature/*`, `fix/*`, `chore/*`
- **Commits:** Conventional Commits (e.g., `feat: add post-deploy health check`)
- **PRs:** Keep them small. Use the PR template. Include risk & rollback.

## Local checks
This repo is Jenkins-driven. Keep scripts readable and idempotent.
- Shell: prefer POSIX; add comments for env vars and paths.
- Groovy: keep Jenkinsfile stages small and named clearly.
