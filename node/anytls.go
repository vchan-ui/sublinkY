package node

import (
	"fmt"
	"net/url"
	"strings"
)

type AnyTLS struct {
	Server   string
	Port     string
	Password string
	SNI      string
	ALPN     string
	Name     string
}

// 编码
func EncodeAnyTLSURL(a AnyTLS) string {
	if a.Name == "" {
		a.Name = a.Server + ":" + a.Port
	}

	return fmt.Sprintf(
		"anytls://%s@%s:%s?sni=%s&alpn=%s#%s",
		a.Password,
		a.Server,
		a.Port,
		a.SNI,
		a.ALPN,
		url.QueryEscape(a.Name),
	)
}

// 解码
func DecodeAnyTLSURL(s string) (AnyTLS, error) {

	if !strings.Contains(s, "anytls://") {
		return AnyTLS{}, fmt.Errorf("非AnyTLS协议")
	}

	u, err := url.Parse(s)
	if err != nil {
		return AnyTLS{}, err
	}

	name := u.Fragment
	if name == "" {
		name = u.Host
	}

	q := u.Query()

	return AnyTLS{
		Server:   u.Hostname(),
		Port:     u.Port(),
		Password: u.User.Username(),
		SNI:      q.Get("sni"),
		ALPN:     q.Get("alpn"),
		Name:     name,
	}, nil
}