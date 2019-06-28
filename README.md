# MAC CONFIG

Inspired by https://github.com/kylecrawshaw/ansible-laptop-config

## Run

```
curl -s https://raw.githubusercontent.com/blaet/mac-config/master/bootstrap.sh | bash
```

## Development

Install macinbox
```
bundle install
```

Create macOS Vagrant box
```
sudo bundle exec macinbox --box-format virtualbox -d 40 --installer [macOS installer location]
```
