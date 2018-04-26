#!/usr/bin/env python
"""Little tool to run MTR on multiple hosts and collect results. Requires MTR and twisted"""
from StringIO import StringIO
import collections
from twisted.internet import reactor
from twisted.internet import defer
from twisted.internet import protocol
from twisted.python import log
import sys

ProcessResult = collections.namedtuple("ProcessResult", "reason stdout stderr")


class DeferredProcess(protocol.ProcessProtocol):
    """Just watch a process storing the output then callback deferred when done"""
    def __init__(self, hostname, args):
        self.stdout = StringIO()
        self.stderr = StringIO()
        self.deferreds = []
        self.result = None
        self.args = args
        self.hostname = hostname

    def log(self, msg):
        log.msg("%s: %s" % (self.hostname, msg))

    def outReceived(self, bytes):
        self.log("stdout received")
        self.stdout.write(bytes)

    def errReceived(self, bytes):
        self.log("stderr received")
        self.stderr.write(bytes)

    def processExited(self, reason):
        self.log("exited")
        self.log("reason: %s" % reason.value)
        self.stdout.write("\nExit result:\n    %s\n%s\n\n" % (reason.value, "=" * 120))
        self.result = ProcessResult(reason, self.stdout.getvalue(), self.stderr.getvalue())
        for deferred in self.deferreds:
            self.callback_deferred(deferred)
        self.deferreds = []

    def callback_deferred(self, deferred):
        deferred.callback(self.result)

    def add_deferred(self, deferred):
        if self.result is None:
            self.deferreds.append(deferred)
        else:
            self.callback_deferred(self.result)

    def connectionMade(self):
        self.log("Starting")
        self.stdout.write("Running:\n    %s\n\n" % (" ".join(self.args)))


class MTR(object):
    """Object to run MTR on multiple hosts and collect results"""
    MTR_PROCESS = "/usr/bin/mtr"

    def __init__(self, combined_report, extra_args=None):
        self.args = (self.MTR_PROCESS, "--report", "--report-cycles=40")
        if extra_args is not None:
            self.args += extra_args
        self.combined_report = combined_report

    @defer.inlineCallbacks
    def mtr_host(self, hostname):
        args = self.args + (hostname,)
        process_protocol = DeferredProcess(hostname, args)
        deferred = defer.Deferred()
        process_protocol.add_deferred(deferred)
        reactor.spawnProcess(process_protocol, self.MTR_PROCESS, args)
        result = yield deferred
        self.combined_report.write(result.stdout + "\n")
        defer.returnValue(result)

    @defer.inlineCallbacks
    def run(self, hosts):
        self.combined_report.write("Compiling MTR report for hosts: %s\n%s\n\n" % (
            ", ".join(hosts),
            "=" * 120))
        deferreds = []
        for host in hosts:
            deferreds.append(self.mtr_host(host))
        yield defer.DeferredList(deferreds)


def mtr(output, hosts, extra_args=None):
    mtr = MTR(output, extra_args)
    return mtr.run(hosts)


@defer.inlineCallbacks
def multiple_mtr(output, hosts):
    yield mtr(output, hosts)
    yield mtr(output, hosts, ("-i0.2",))
    yield mtr(output, hosts, ("-u",))
    yield mtr(output, hosts, ("-u", "-i0.2"))
    reactor.stop()


if __name__ == "__main__":
    output = sys.stdout
    hosts = sys.argv[1:]
    multiple_mtr(output, hosts)
    reactor.run()
