# chezmoi를 이용한 환경설정 동기화하기

https://www.chezmoi.io/

## 신규 동기화 파일 추가하기

```sh
chezmoi add <file>

# ex) chezmoi add ~/.zshrc
```

## 설정 수정하기

```sh
chezmoi edit <file>

# ex) chezmoi edit ~/.zshrc
```

chezmoi edit을 이용하면 git에도 바로 반영된다

별도로 로컬에서 수정하고 chezmoi git에 반영하고 싶다면

```sh
chezmoi re-add <file>

# 관리하는 전체 파일이 re-add
chezmoi re-add
```

## 설정 가져오기

```sh
chezmoi apply
```

## git에 반영하기

```sh
chezmoi cd
```

이동한 디렉토리에서 일반적인 명령어로 git push까지 진행하면 된다.

## chezmoi config

```sh
chezmoi edit-config
```

`chezmoi.toml` 파일을 열어준다.

난 현재 아래의 설정을 적용해둠

```toml

[edit]
  command = "nvim"
  autoCommit = true

[merge]
  command = "nvim"
  # 3-way diff
  args = ["-d", "{{ .Destination }}", "{{ .Source }}", "{{ .Target }}"]
```

## 변수 설정

환경별로 다른 항목들은 변수로 관리할 수 있다.

```sh
chezmoi edit-config
```

```toml
...

[data]
  workspace_path = '~/Documents/workspace'
```

위처럼 입력하고 다음처럼 참고할 수 있다. 
그 전에 변수를 반영할 파일을 "템플릿"으로 추가해야 한다.

```sh
chezmoi add --template <file>
```

```md
alias cdwork = 'cd {{ .workspace_path }}'
```

config에 입력한 값이 apply 시에 자동 반영된다.


## Data 목록 

이 레포에서 내가 쓰는 data 리스트를 여기에 관리함

```toml
[data]
  workspace_path = ''
```
