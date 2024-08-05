echo "" | Out-File -FilePath $PSHOME\Profile.ps1 -Append # just to add a newline
echo "Set-PSReadLineOption -EditMode Emacs" | Out-File -FilePath $PSHOME\Profile.ps1 -Append
set-ExecutionPolicy RemoteSigned