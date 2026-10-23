FROM golang:latest@sha256:f38c7f7bbaca5d664e39cd982a1cb5b6f8e999244e9ddb6ec8ba098438b3f4da AS builder

WORKDIR /src
COPY . .

RUN go build -o /out/my-bin .

FROM scratch AS bin
COPY --from=builder /out/my-bin /
ENTRYPOINT ["/my-bin"]
