FROM public.ecr.aws/docker/library/golang:1.19.9-alpine3.18 as builder
WORKDIR /app
RUN apk update && apk upgrade && \
    apk add bash git openssh gcc libc-dev
COPY ./go.mod ./

ENV GOSUMDB off
COPY ./ ./
RUN go build -o /dist/server *.go

FROM public.ecr.aws/docker/library/alpine:3.17.3

COPY --from=builder /dist/server /app/bin/server
WORKDIR /app/bin
CMD ["/app/bin/server"]
