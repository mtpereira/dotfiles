# aws
complete -C '$(which aws_completer)' aws

# docker
fpath=(\
  /usr/share/zsh/site-functions/_docker \
  /usr/share/zsh/site-functions/_docker-compose \
$fpath \
)

