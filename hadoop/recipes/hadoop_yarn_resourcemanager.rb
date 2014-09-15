#
# Cookbook Name:: hadoop
# Recipe:: hadoop_yarn_resourcemanager
#
# Copyright (C) 2013-2014 Continuuity, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe 'hadoop::default'

package 'hadoop-yarn-resourcemanager' do
  action :install
end

# TODO: check for these and set them up
# mapreduce.cluster.local.dir = #{hadoop_tmp_dir}/mapred/local
# mapreduce.jobtracker.system.dir = #{hadoop_tmp_dir}/mapred/system
# mapreduce.jobtracker.staging.root.dir = #{hadoop_tmp_dir}/mapred/staging
# mapreduce.cluster.temp.dir = #{hadoop_tmp_dir}/mapred/temp

# We need a /tmp in HDFS
dfs = node['hadoop']['core_site']['fs.defaultFS']
execute 'hdfs-tmpdir' do
  command "hdfs dfs -mkdir -p #{dfs}/tmp && hdfs dfs -chmod 1777 #{dfs}/tmp"
  timeout 300
  user 'hdfs'
  group 'hdfs'
  action :nothing
end

remote_log_dir =
  if node['hadoop'].key?('yarn_site') && node['hadoop']['yarn_site'].key?('yarn.nodemanager.remote-app-log-dir')
    node['hadoop']['yarn_site']['yarn.nodemanager.remote-app-log-dir']
  else
    '/tmp/logs'
  end

node.default['hadoop']['yarn_site']['yarn.nodemanager.remote-app-log-dir'] = remote_log_dir

execute 'yarn-remote-app-log-dir' do
  command "hdfs dfs -mkdir -p #{remote_log_dir} && hdfs dfs -chown yarn:hadoop #{remote_log_dir} && hdfs dfs -chmod 1777 #{remote_log_dir}"
  timeout 300
  user 'hdfs'
  group 'hdfs'
  not_if "hdfs dfs -test -d #{remote_log_dir}", :user => 'hdfs'
  action :nothing
end

service 'hadoop-yarn-resourcemanager' do
  status_command 'service hadoop-yarn-resourcemanager status'
  supports [:restart => true, :reload => false, :status => true]
  action :nothing
end
