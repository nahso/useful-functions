echo "" | Out-File -FilePath $PSHOME\Profile.ps1 -Append
echo "Set-PSReadLineOption -EditMode Emacs" | Out-File -FilePath $PSHOME\Profile.ps1 -Append
set-ExecutionPolicy RemoteSigned