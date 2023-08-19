package servermain

import (
	"context"

	"capnproto.org/go/capnp/v3/exc"
	"zenhack.net/go/tempest/capnp/external"
	"zenhack.net/go/tempest/internal/common/types"
	"zenhack.net/go/tempest/internal/server/database"
	"zenhack.net/go/tempest/internal/server/session"
	"zenhack.net/go/util/exn"
)

type uiViewControllerImpl struct {
	GrainID types.GrainID
	Session session.UserSession
	DB      database.DB
}

func (c uiViewControllerImpl) MakeSharingToken(ctx context.Context, p external.UiView_Controller_makeSharingToken) error {
	return exn.Try0(func(throw exn.Thrower) {
		wantPerms, err := p.Args().Permissions()
		throw(err)
		note, err := p.Args().Note()
		throw(err)
		results, err := p.AllocResults()
		throw(err)
		tx, err := c.DB.Begin()
		throw(err)
		defer tx.Rollback()
		accountID, err := tx.CredentialAccount(c.Session.Credential)
    err = exc.WrapError("no account for credential", err)
		throw(err)
		perms, err := tx.AccountGrainPermissions(accountID, c.GrainID)
    err = exc.WrapError("failed to fetch permissions", err)
		throw(err)
		if len(perms) < wantPerms.Len() {
			perms = perms[:wantPerms.Len()]
		}
		for i := range perms {
			perms[i] = perms[i] && wantPerms.At(i)
		}
		token, err := tx.NewSharingToken(c.GrainID, perms, note)
		throw(err)
		throw(tx.Commit())
		throw(results.SetToken(token))
	})
}
