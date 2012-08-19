#! /usr/bin/env python
# -*- coding: utf-8 -*-
#
#   rebuildorder.py - find the order to build a list of packages
#
#   Copyright (c) 2010 by Mark Pustjens <pustjens@dds.nl>
#   Copyright (c) 2009 by Allan McRae <allan@archlinux.org>
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

import os, sys, re
from collections import deque
from optparse import OptionParser

def get_pkgs(pkgfile):
	try:
		f = open(pkgfile)
	except IOError:
		print "Error: could not read packages file '%s'" % pkgfile
	
	pkgs = set(f.read().split())

	return pkgs

def find_pkgbuild(abspath, pkg):
	cmd = 'find %s -wholename "*/%s/PKGBUILD" -print' % (abspath, pkg)

	files = os.popen(cmd).readlines()

	if len(files) >= 1:
		return files[0][:-1]
	else:
		return None

def get_deps_from_pkgbuild(pkgbuild_file):
	pkgbuild = open(pkgbuild_file)
	deps = set()
	makedeps = set()

	for line in pkgbuild.readlines():
		m = re.match("^depends=\((.*)\)", line)
		if m is not None:
			for pkg in m.group(1).split(" "):
				pkg = pkg.strip("'\"")
				pkg = pkg.split(">")[0].split("<")[0].split("=")[0]
				deps.add(pkg)

		m = re.match("^makedepends=\((.*)\)", line)
		if m is not None:
			for pkg in m.group(1).split(" "):
				pkg = pkg.strip("'\"")
				pkg = pkg.split(">")[0].split("<")[0].split("=")[0]
				makedeps.add(pkg)

	return (deps, makedeps)

def get_deps_from_pacman(package):
	deps = set()

	pkginfo = os.popen("pacman -Si " + package + " 2> /dev/null").read().split("\n")
	if pkginfo != ['']:
		found = False
		for i in pkginfo:
			if not found:
				if i[0:10] == "Depends On":
					deplist = i.split()[3:]
					found = True
			else:
				if i[0] != " ":
					break
				deplist += i.split()

		for i in deplist:
			pkg = i.split(">")[0].split("<")[0].split("=")[0]
			deps.add(pkg)
	
	return deps
		
def bfsa(G, D, R):
	"""
	BFS Search on graph G, using the set R as the graph roots.
	This BFS only visits a node if all its parents have been visisted.
	D is the reverse adjacency list representation of G.
	Nodes which are part of a cycle are not in the output.
	"""


	Q = deque(R)
	visited = set(R)

	while Q:
		v = Q.pop()
		visited.add(v)
		yield v

		for w in G[v]:
			if w not in visited and (D[w] & visited) == D[w]:
				visited.add(w)
				Q.appendleft(w)


def main():
	usage = "usage: %prog [options] -p <pkgfile>"
	parser = OptionParser(usage)

	parser.add_option('-p', '--pkg', dest="pkgfile", nargs=1,
			metavar="<pkgfile>", help="File containing a list of packages.")
	parser.add_option('-c', '--cycles', action="store_true", dest="cycles_only",
			help="Show only packages which have circular dependencies.")
	parser.add_option('-m', '--makedeps', action="store_true", dest="makedeps",
			help="Automatically add makedeps to package list.")
	parser.add_option('-a', '--abs', dest="abspath", nargs=1,
			help="Path to ABS.")

	parser.set_defaults(pkgfile=None, cycles_only=False, makedeps=False, abspath=".")

	(options, args) = parser.parse_args()

	if options.pkgfile is None:
		parser.error("No package file name provided.")
		exit(1)

	pkgs = get_pkgs(options.pkgfile)

	"""
	Q is a queue of all packages to be processed
	G is the graph of dependencies (i depends on D[i])
	D is the graph of requirements (i requires G[i]) (reversed G)
	R is the list of graph roots of G
	O is the ordered list of packages. Packages on top need to be compiled first.
	O does not contain packages with circular dependencies.
	"""

	Q = deque(pkgs)
	G = {}
	D = {}
	R = []
	M = set()

	""" Fill G """
	while Q:
		pkg = Q.pop()

		if pkg in G.keys():
			continue

		pkgbuild = find_pkgbuild(options.abspath, pkg)

		"""
		Determine all dependencies, including makedeps.
		Try abs first and if that fails, use pacman.
		This is because only abs includes makedeps.
		"""
		if pkgbuild is not None:
			try:
				(deps, makedeps) = get_deps_from_pkgbuild(pkgbuild)
			except IOError:
				makedeps = set()
				deps = get_deps_from_pacman(pkg)
		else:
			makedeps = set()
			deps = get_deps_from_pacman(pkg)

		if options.makedeps:
			G[pkg] = (deps & pkgs) | makedeps # weed out deps not in the packages list, but keep makedeps
			D[pkg] = set()

			# we also need to process all makedeps (if requested on commandline)
			for makedep in makedeps:
				Q.appendleft(makedep)
				M.add(makedep)
		else:
			G[pkg] = deps & pkgs
			D[pkg] = set()

	""" Fill D """
	for pkg in G.keys():
		for dep in G[pkg]:
			D[dep].add(pkg)

	""" Fill R """
	R = [key for key in G.keys() if len(G[key]) == 0]

	""" Fill O """
	O = list(bfsa(D, G, R))

	if not options.cycles_only:
		""" print O """
		for pkg in O:
			print pkg

	""" print all packages not in O (i.e those whith circular dependencies) """
	for pkg in G.keys():
		if pkg not in O:
			print pkg

if __name__ == "__main__":
    main()
