#!/usr/bin/python

from mininet.net import Mininet
from mininet.node import Controller, RemoteController, OVSController
from mininet.node import CPULimitedHost, Host, Node
from mininet.node import OVSKernelSwitch, UserSwitch
from mininet.node import IVSSwitch
from mininet.cli import CLI
from mininet.log import setLogLevel, info
from mininet.link import TCLink, Intf
from subprocess import call

def myNetwork():

    net = Mininet( topo=None,
                   build=False,
                   ipBase='10.0.0.0/8')

    info( '*** Adding controller\n' )
    info( '*** Add switches\n')
    s1 = net.addSwitch('s1', cls=OVSKernelSwitch, failMode='standalone')
    s2 = net.addSwitch('s2', cls=OVSKernelSwitch, failMode='standalone')
    s3 = net.addSwitch('s3', cls=OVSKernelSwitch, failMode='standalone')

    info( '*** Add hosts\n')
    net.addLink(s1, s2)
    net.addLink(s2, s3)

    i = 1
    hosts = {}
    while i <= 20:
        hosts[i] = net.addHost('h'+str(i), cls=Host, ip=('10.0.0.'+str(i)), defaultRoute=None)
        net.addLink(hosts[i], s1)
        i += 1
    

    i = 21
    while i <= 40:
        hosts[i] = net.addHost('h'+str(i), cls=Host, ip=('10.0.0.'+str(i)), defaultRoute=None)
        net.addLink(hosts[i], s3)
        i += 1
    
    info( '*** Add links\n')
    
    info( '*** Starting network\n')
    net.build()
    info( '*** Starting controllers\n')
    for controller in net.controllers:
        controller.start()

    info( '*** Starting switches\n')
    net.get('s2').start([])
    net.get('s1').start([])
    net.get('s3').start([])

    info( '*** Post configure switches and hosts\n')

    CLI(net)
    net.stop()

if __name__ == '__main__':
    setLogLevel( 'info' )
    myNetwork()


