package handlers

import "fmt"

type IHandler interface {
	Handle() IHandler
	JSON() error
	SetError(err error) IHandler
	SetCode(code int) IHandler
	Code() int
	Data() any
	Error() error
}

func Lock(h IHandler, code int, err error) IHandler {
	h.SetCode(code)
	h.SetError(fmt.Errorf("%d Error: %s", code, err.Error()))
	// get the handler name
	typeName := fmt.Sprintf("%T", h)
	fmt.Printf("[ERROR] %s.Lock{ err: %v }\n", typeName, err)
	return h
}
