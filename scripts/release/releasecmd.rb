#!/usr/bin/ruby
=begin
***************************************************************************
*   Copyright (C) 2008 by Volker Lanz <vl@fidra.de>                       *
*                                                                         *
*   This program is free software; you can redistribute it and/or modify  *
*   it under the terms of the GNU General Public License as published by  *
*   the Free Software Foundation; either version 2 of the License, or     *
*   (at your option) any later version.                                   *
*                                                                         *
*   This program is distributed in the hope that it will be useful,       *
*   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
*   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
*   GNU General Public License for more details.                          *
*                                                                         *
*   You should have received a copy of the GNU General Public License     *
*   along with this program; if not, write to the                         *
*   Free Software Foundation, Inc.,                                       *
*   51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA            *
***************************************************************************
=end

require 'releasebuilder.rb'

def usage
	puts <<END_OF_TEXT
#{$0} [options]
where options are:
    --product-name (-p)
    --application-name (-a)
    --version (-v)
    --checkout-from (-c): trunk (default), stable, tag
    --tag (-t): name of tag
    --svn-access (-s): https, svn+ssh, anonsvn (default)
    --get-docs (-d): also get documentation (default)
    --no-get-docs (-D): do not get documentation
    --get-translations (-r): also get translations (default)
    --no-get-translations (-R): do not get translations
    --create-tag (-e): create a new tag
    --no-create-tag (-E): do not create a new tag (default)
    --create-tarball (-b): create a tarball (default)
    --no-create-tarball (-B): do not create a tarball
    --help (-h): show this usage
Possible values for product-name:
END_OF_TEXT
	ReleaseBuilder.sortedProducts.each { |p| puts '    "' + p + '"' }
	puts 'Possible values for application-name:'
	ReleaseBuilder.sortedAppNames.each { |a| puts '    "' + a + '"' }
end

opts = GetoptLong.new(
	[ '--product-name', '-p', GetoptLong::REQUIRED_ARGUMENT ],
	[ '--application-name', '-a', GetoptLong::REQUIRED_ARGUMENT ],
	[ '--version', '-v', GetoptLong::REQUIRED_ARGUMENT ],
	[ '--checkout-from', '-c', GetoptLong::REQUIRED_ARGUMENT ],
	[ '--tag', '-t', GetoptLong::REQUIRED_ARGUMENT ],
	[ '--svn-access', '-s', GetoptLong::REQUIRED_ARGUMENT ],
	[ '--svn-user', '-u', GetoptLong::REQUIRED_ARGUMENT ],
	[ '--get-docs', '-d', GetoptLong::NO_ARGUMENT ],
	[ '--no-get-docs', '-D', GetoptLong::NO_ARGUMENT ],
	[ '--get-translations', '-r', GetoptLong::NO_ARGUMENT ],
	[ '--no-get-translations', '-R', GetoptLong::NO_ARGUMENT ],
	[ '--create-tag', '-e', GetoptLong::NO_ARGUMENT ],
	[ '--no-create-tag', '-E', GetoptLong::NO_ARGUMENT ],
	[ '--create-tarball', '-b', GetoptLong::NO_ARGUMENT ],
	[ '--np-create-tarball', '-B', GetoptLong::NO_ARGUMENT ],
	[ '--help', '-h', GetoptLong::NO_ARGUMENT ]
)

productName = nil
appName = nil
version = nil
checkoutFrom = 'trunk'
tag = ''
protocol = 'anonsvn'
user = ''
getDocs = true
getTranslations = true
createTag = false
createTarball = true

opts.each do |opt, arg|
	case opt
		when '--product-name' then productName = arg
		when '--application-name' then appName = arg
		when '--version' then version = arg
		when '--checkout-from' then checkoutFrom = arg
		when '--tag' then tag = arg
		when '--svn-access' then protocol = arg
		when '--svn-user' then user = arg
		when '--get-docs' then getDocs = true
		when '--no-get-docs' then getDocs = false
		when '--get-translations' then getTranslations = true
		when '--no-get-translations' then getTranslations = false
		when '--create-tag' then createTag = true
		when '--no-create-tag' then createTag = false
		when '--create-tarball' then createTarball = true
		when '--no-create-tarball' then createTarball = false
		when '--help' then usage; exit
	end
end

if not productName and not appName
	puts "You must either specify a product name or an application name."
	exit
end

if not version
	puts "Version can not be empty."
	exit
end

app = productName ? ReleaseBuilder.findAppByProduct(productName) : ReleaseBuilder.findAppByName(appName)
if not app
	puts "Could not find product."
	exit
end

if protocol != 'anonsvn' and user.empty?
	puts "The SVN protocol '#{protocol}' requires a user name."
	exit
end

if checkoutFrom == 'tag' and tag.empty?
	puts "Cannot check out from tag dir if tag is empty."
	exit
end

repository = ReleaseBuilder.repository(app.product, protocol, user, checkoutFrom != 'tag' ? checkoutFrom : tag)

releaseBuilder = ReleaseBuilder.new(Dir.getwd, repository, app.product, version)
releaseBuilder.run(protocol, user, createTarball, getTranslations, getDocs, createTag)
