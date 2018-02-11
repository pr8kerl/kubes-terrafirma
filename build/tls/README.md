# generate CA cert

```
cfssl gencert -initca ca-csr.json | cfssljson -bare ca -
```
