# JJ Tools

Centralized repository for JJ (Jujutsu) workflow utility scripts.

## Scripts Included

- **`jj-tug.sh`**: Fetches latest changes, rebases onto `main`, moves the `main` bookmark, and pushes to GitHub.
- **`jj-git-main.sh`**: Moves a jj bookmark (default `main`) to **`git HEAD`** in a **colocated** repo. Use after **git-only** commits left jj’s bookmark behind; this is **not** what `jj tug` does (`jj tug` follows rebase/export/push to **origin/main**, not arbitrary git HEAD).
- **`jj-ws-merge.sh`**: Merges work from a feature workspace into the main workspace, exports to Git, and resets the feature workspace.
- **`jj-ws-sync.sh`**: Rebases a feature workspace onto the current tip of `default@`, useful for keeping long-lived workspaces up to date.
- **`jj-sync.sh`**: Syncs the main workspace, updates stale pointers, and seals squashed changes into a new commit.
- **`jj-pr.sh`**: Helper for bookmark-based PR workflows (pushing bookmarks and syncing with trunk).

## Setup

1. Clone this repository:
   ```bash
   git clone [repo-url] /path/to/jj-tools
   ```
2. Make sure the scripts are executable:
   ```bash
   chmod +x /path/to/jj-tools/scripts/*.sh
   ```
3. Update your `~/.config/jj/config.toml` with the following aliases:

```toml
[aliases]
tug       = ["util", "exec", "--", "/path/to/jj-tools/scripts/jj-tug.sh"]
git-main  = ["util", "exec", "--", "/path/to/jj-tools/scripts/jj-git-main.sh"]
ws-merge  = ["util", "exec", "--", "/path/to/jj-tools/scripts/jj-ws-merge.sh"]
ws-sync   = ["util", "exec", "--", "/path/to/jj-tools/scripts/jj-ws-sync.sh"]
sync      = ["util", "exec", "--", "/path/to/jj-tools/scripts/jj-sync.sh"]
pr        = ["util", "exec", "--", "/path/to/jj-tools/scripts/jj-pr.sh"]
```

## Workflows

These tools support three primary development styles with JJ.

### 1. Single-Workspace Trunk-Based
Ideal for rapid, single-dev trunk-based development within a single repository folder.

#### **Flow:**
1. **Sync**: Keep your history clean and up-to-date.
   ```bash
   jj sync      # Fixes staleness and 'seals' your working copy
   ```
2. **Commit**: Just describe your current work.
   ```bash
   jj describe -m "fix: logic error"
   ```
3. **Ship**: Fetch, rebase, and push in one go.
   ```bash
   jj tug
   ```

---

### 2. Multi-Workspace Feature Flow
Recommended for working on complex features in a separate directory (`repo-feature`) while keeping the main repository (`repo-main`) clean.

#### **Step A: Feature Workspace**
1. **Merge**: Bring changes into the main repository.
   ```bash
   jj ws-merge "feat: my new feature"  # Describes, squashes into default@, and exports to Git
   ```

#### **Step B: Main Workspace**
1. **Sync**:
   ```bash
   cd ../repo-main
   jj sync      # Finalize the merge and start a fresh scratchpad
   ```
2. **Ship**:
   ```bash
   jj tug
   ```

#### **Step C: Catch Up Feature Workspace** *(after shipping or pulling new work)*
If you've shipped other work in the main workspace and want your feature workspace to be based on the latest:
1. **Go to feature workspace**:
   ```bash
   cd ../repo-feature
   jj ws-sync   # Rebases your feature workspace onto the current tip of default@
   ```

---

### 3. Feature Branching / PR Flow (Bookmarks)
Used for traditional PR-based development where features are isolated on bookmarks (branches).

#### **Flow:**
1. **Start a Branch**:
   ```bash
   jj bookmark create my-feature
   jj new my-feature  # Start work on the bookmark
   ```
2. **Commit**: Describe your changes.
   ```bash
   jj describe -m "feat: description"
   ```
3. **Push to PR**: Use the helper to push your bookmark.
   ```bash
   jj pr push   # Automatically updates/creates your feature bookmark and pushes
   ```
4. **Sync with Main**:
   ```bash
   jj pr sync   # Fetches and rebases your feature onto trunk()
   ```

---

## Tips & Troubleshooting

- **`jj log main` vs `git log` disagree (colocated repo)**: Often `git HEAD` moved (e.g. commits via `git`) but the jj bookmark `main` did not. Run **`jj git-main`** (or `path/to/jj-git-main.sh`) from the project root. Optional bookmark name: `jj git-main other-bookmark`. This does not fetch or push; it only points jj at the current git revision.
- **Stale Working Copy**: If JJ says your working copy is stale, it means another workspace updated the commit you are on. Run `jj sync` or `jj workspace update-stale`.
- **Git Sync**: If Git isn't seeing your JJ changes, run `jj git export`. Our scripts handle this automatically.
- **Empty Commits**: If you have a dangling "no description set" commit after a squash, run `jj abandon` or simply use `jj sync` to start fresh.
