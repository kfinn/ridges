# syntax = docker/dockerfile:1.2

FROM alpine:3.23
RUN apk add zig=0.15.2-r0
COPY . app
RUN cd app && zig build -Denvironment=production; cd /

FROM alpine:3.23
WORKDIR /app
COPY --from=0 app/zig-out/assets app/zig-out/bin .

ENTRYPOINT ["bin/ridges"]
CMD ["server"]

EXPOSE 5882
