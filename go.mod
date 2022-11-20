module zenhack.net/go/sandstorm-next

go 1.19

// NOTE: this *must not* be updated to v1.11; that version drops support for
// version 2 of the wire protocol, which is the most recent supported by the
// (ancient) version of mongo bundled with legacy sandstorm.
require go.mongodb.org/mongo-driver v1.10.0

require (
	capnproto.org/go/capnp/v3 v3.0.0-alpha.9
	github.com/gorilla/mux v1.8.0
	github.com/gorilla/websocket v1.5.0
	github.com/mattn/go-sqlite3 v1.14.16
	github.com/stretchr/testify v1.7.0
	golang.org/x/sys v0.0.0-20220728004956-3c1f35247d10
	zenhack.net/go/sandstorm v0.0.0-20220806194653-4d4ad4418a15
	zenhack.net/go/util v0.0.0-20221015181152-e65f93a0f343
	zenhack.net/go/vdom v0.0.0-20221104044328-f3b1dd7f4360
	zenhack.net/go/websocket-capnp v0.0.0-20221120211354-9ebea22406ad
)

require (
	github.com/davecgh/go-spew v1.1.1 // indirect
	github.com/golang/snappy v0.0.1 // indirect
	github.com/klauspost/compress v1.13.6 // indirect
	github.com/montanaflynn/stats v0.0.0-20171201202039-1bf9dbcd8cbe // indirect
	github.com/pkg/errors v0.9.1 // indirect
	github.com/pmezard/go-difflib v1.0.0 // indirect
	github.com/xdg-go/pbkdf2 v1.0.0 // indirect
	github.com/xdg-go/scram v1.1.1 // indirect
	github.com/xdg-go/stringprep v1.0.3 // indirect
	github.com/youmark/pkcs8 v0.0.0-20181117223130-1be2e3e5546d // indirect
	golang.org/x/crypto v0.0.0-20220622213112-05595931fe9d // indirect
	golang.org/x/sync v0.0.0-20210220032951-036812b2e83c // indirect
	golang.org/x/text v0.3.7 // indirect
	gopkg.in/yaml.v3 v3.0.1 // indirect
)
