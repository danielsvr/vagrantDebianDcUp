PUTTYGEN $(Get-Item $($(vagrant ssh-config | sls IdentityFile).ToString().Split(' ') | select -Last 1))
