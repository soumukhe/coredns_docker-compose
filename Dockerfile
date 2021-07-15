FROM coredns/coredns:1.7.0

LABEL maintainer="Burke Azbill"

EXPOSE 53 53/udp
#VOLUME ["/etc/coredns"]   # creates the mountpoint only.  Not needed because docker-compose creates and maps
ENTRYPOINT ["/coredns"]
CMD ["-conf", "/etc/coredns/Corefile"]
