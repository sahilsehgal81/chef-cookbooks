maintainer       "Inspiredtechies"
maintainer_email "sahil@inspiredtechies.com"
license          "All rights reserved"
description      "various apache server related resource provides (LWRP)"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.0.5"
depends 	 "apache2"

%w{ gentoo ubuntu }.each do |os|
  supports os
end
