# 🌿 Git Branch Workflow - RazakEvent

## Branch Structure

| Branch | Purpose | Who creates |
|--------|---------|-------------|
| `main` | Production-ready code | Already exists |
| `dev` | Development integration branch | Created (RE-23 completed) |
| `feature/RE-XX` | Individual features/tasks | Each developer |

## Workflow Rules

1. ✅ **NEVER** commit directly to `main` or `dev`
2. ✅ **ALWAYS** create a `feature` branch from `dev`
3. ✅ **ALWAYS** open a Pull Request (PR) to merge into `dev`
4. ✅ **ALWAYS** get at least 1 team member approval before merging
5. ✅ **Project Manager** handles merging `dev` → `main` after testing

## How to Start a New Task

```bash
# 1. Switch to dev and get latest
git checkout dev
git pull origin dev

# 2. Create your feature branch (use Jira task ID)
git checkout -b feature/RE-23-branch-workflow

# 3. Make your changes
# (edit files, add code, etc.)

# 4. Commit and push
git add .
git commit -m "RE-23: Add branch workflow documentation"
git push origin feature/RE-23-branch-workflow

# 5. Create Pull Request on GitHub


## How to Create a Pull Request (PR)

1. Go to GitHub → Pull Requests tab
2. Click "New Pull Request"
3. Set: `base: dev` ← `compare: feature/your-branch-name`
4. Add title: "RE-XX: Description of work"
5. Click "Create Pull Request"
6. Request review from a teammate
7. After approval, click "Merge pull request"

## Current Branches (April 25, 2026)

- ✅ `main` - production
- ✅ `dev` - development (created)
- ⏳ `feature/*` - create when starting tasks

---

**Workflow approved by:** RazakEvent Team  
**Date:** April 25, 2026
