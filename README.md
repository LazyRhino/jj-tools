# JJ Tools

Centralized repository for JJ (Jujutsu) workflow utility scripts.

## Scripts Included

- **`jj-tug.sh`**: Fetches latest changes, rebases onto `main`, moves the `main` bookmark, and pushes to GitHub.
- **`jj-ws-merge.sh`**: Merges work from a feature workspace into the main workspace, exports to Git, and resets the feature workspace.
- **`jj-sync.sh`**: Syncs the main workspace, updates stale pointers, and seals squashed changes into a new commit.

## Setup

1. Clone this repository:
   ```bash
   git clone [repo-url] ~/code/jj-tools
   ```
2. Make sure the scripts are executable:
   ```bash
   chmod +x ~/code/jj-tools/scripts/*.sh
   ```
3. Update your `~/.config/jj/config.toml` with the following aliases:

```toml
[aliases]
tug      = ["util", "exec", "--", "/home/rhyno/code/jj-tools/scripts/jj-tug.sh"]
ws-merge = ["util", "exec", "--", "/home/rhyno/code/jj-tools/scripts/jj-ws-merge.sh"]
sync     = ["util", "exec", "--", "/home/rhyno/code/jj-tools/scripts/jj-sync.sh"]
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
1. **Develop & Name**:
   ```bash
   jj describe -m "feat: my new feature"
   ```
2. **Merge**: Bring changes into the main repository.
   ```bash
   jj ws-merge  # Squashes feature into default@ and exports to Git
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

- **Stale Working Copy**: If JJ says your working copy is stale, it means another workspace updated the commit you are on. Run `jj sync` or `jj workspace update-stale`.
- **Git Sync**: If Git isn't seeing your JJ changes, run `jj git export`. Our scripts handle this automatically.
- **Empty Commits**: If you have a dangling "no description set" commit after a squash, run `jj abandon` or simply use `jj sync` to start fresh.
