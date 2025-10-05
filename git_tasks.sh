git checkout feature/login-system
git pull origin feature/login-system
git revert <hash-of-D>

git reset --mixed HEAD~1
# edit files
git add .
git commit -m "Improved quick fix for login bug"

git reset --mixed HEAD~3
git add <file1> <file2>
git commit -m "Partial commit of safe changes"

git reset --hard HEAD~3
