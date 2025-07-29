Name:     cookbook-rb-agents
Version:  %{__version}
Release:  %{__release}%{?dist}
BuildArch: noarch
Summary: rb-agents cookbook to install and configure it in redborder-agents service


License:  GNU AGPLv3
URL:  https://github.com/redBorder/cookbook-rb-agents
Source0: %{name}-%{version}.tar.gz

%description
%{summary}

%prep
%setup -qn %{name}-%{version}

%build

%install
mkdir -p %{buildroot}/var/chef/cookbooks/rb-agents
mkdir -p %{buildroot}/usr/lib64/rb-agents

cp -f -r  resources/* %{buildroot}/var/chef/cookbooks/rb-agents/
chmod -R 0755 %{buildroot}/var/chef/cookbooks/rb-agents
install -D -m 0644 README.md %{buildroot}/var/chef/cookbooks/rb-agents/README.md

%pre

%post
case "$1" in
  1)
    # This is an initial install.
    :
  ;;
  2)
    # This is an upgrade.
    su - -s /bin/bash -c 'source /etc/profile && rvm gemset use default && env knife cookbook upload rb-agents'
  ;;
esac

systemctl daemon-reload
%files
%attr(0755,root,root)
/var/chef/cookbooks/rb-agents
%defattr(0644,root,root)
/var/chef/cookbooks/rb-agents/README.md

%doc

%changelog
* Thu Jul 24 2025 - manegron <manegron@redborder.com> - 0.0.1-1
- Initial spec version
