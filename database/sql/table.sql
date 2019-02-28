create schema workflow_new collate latin1_swedish_ci;

create table dept
(
	id int auto_increment
		primary key,
	dept_name varchar(64) default '' not null,
	pid int default 0 not null,
	director_id int default 0 not null comment '部门主管 0表示不存在',
	manager_id int default 0 not null comment '部门经理 0表示不存在',
	`rank` int default 1 not null,
	created_at timestamp default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP,
	updated_at timestamp default '2018-12-12 00:00:00' not null
)
comment '部门表' collate=utf8mb4_bin;

create index dept_name
	on dept (dept_name);

create index pid
	on dept (pid);

create table emp
(
	id int unsigned auto_increment
		primary key,
	name varchar(191) not null,
	email varchar(191) not null,
	password varchar(191) not null,
	workno varchar(32) not null comment '工号',
	dept_id int default 0 not null comment '部门id',
	`leave` smallint(6) default 0 not null comment '离职状态',
	remember_token varchar(100) null,
	created_at timestamp null,
	updated_at timestamp null,
	deleted_at timestamp null,
	constraint users_email_unique
		unique (email),
	constraint users_workno_unique
		unique (workno)
)
collate=utf8mb4_unicode_ci;

create table entry
(
	id int auto_increment
		primary key,
	title varchar(45) default '' not null comment '标题',
	flow_id int default 0 not null,
	emp_id int default 0 not null comment '发起人',
	process_id int default 0 not null comment '当前步骤id',
	circle smallint(6) default 1 not null comment '第几轮申请',
	status int not null comment '当前状态 0处理中 9通过 -1驳回 -2撤销 -9草稿 1：流程中 9：处理完成',
	pid int default 0 not null comment '父流程',
	enter_process_id int default 0 not null comment '进入子流程的父流程步骤id',
	enter_proc_id int default 0 not null comment '进入子流程的进程id',
	child int default 0 not null comment '子流程 process_id',
	created_at timestamp null,
	updated_at timestamp null
)
comment '流程实例' collate=utf8mb4_bin;

create index emp_id
	on entry (emp_id);

create index step_id
	on entry (process_id);

create index workflow_id
	on entry (flow_id);

create table entry_data
(
	id int auto_increment
		primary key,
	entry_id int default 0 not null,
	flow_id int default 0 not null,
	field_name varchar(128) default '' not null,
	field_value text null,
	field_remark varchar(255) default '' not null,
	created_at timestamp null,
	updated_at timestamp null
)
comment '实例数据表' collate=utf8mb4_bin;

create index entry_id
	on entry_data (entry_id);

create index workflow_id
	on entry_data (flow_id);

create table flow
(
	id int auto_increment
		primary key,
	flow_no varchar(45) not null comment '工作流编号',
	flow_name varchar(45) default '' not null comment '工作流名称',
	template_id int(255) default 0 not null,
	flowchart text null,
	jsplumb text null comment 'jsplumb流程图数据',
	type_id int default 0 not null comment '流程设计文件',
	is_publish tinyint default 0 not null comment '是否发布，发布后可用',
	is_show tinyint default 1 not null comment '是否显示',
	created_at timestamp default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP,
	updated_at timestamp default '2018-12-12 00:00:00' not null
)
comment '工作流定义表' collate=utf8mb4_bin;

create table flow_type
(
	id int auto_increment
		primary key,
	type_name varchar(64) default '' not null,
	created_at timestamp default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP,
	updated_at timestamp default '2018-12-12 00:00:00' not null
)
comment '流程分类表' collate=utf8mb4_bin;

create index type_name
	on flow_type (type_name);

create table flowlink
(
	id bigint auto_increment
		primary key,
	flow_id int not null comment '流程id',
	type varchar(45) not null comment 'Condition:表示步骤流转Role:当前步骤操作人',
	process_id int not null comment '当前步骤id',
	next_process_id int default -1 not null comment '下一个步骤 Condition -1未指定 0结束 -9上级查找 type=Role时为0，不启用',
	auditor varchar(255) default '0' not null comment '审批人 系统自动 指定人员 指定部门 指定角色 type=Condition时不启用',
	expression varchar(255) default '' not null comment '条件判断表达式为1表示true，通过的话直接进入下一步骤',
	sort int not null comment '条件判断顺序',
	created_at timestamp null,
	updated_at timestamp null
)
comment '流程步骤流转轨迹' collate=utf8mb4_bin;

create index emp_id
	on flowlink (auditor);

create index step_id
	on flowlink (process_id);

create index workflow_id
	on flowlink (flow_id);

create table proc
(
	id int auto_increment
		primary key,
	entry_id int not null,
	flow_id int not null comment '流程id',
	process_id int not null comment '当前步骤',
	process_name varchar(255) default '' not null comment '当前步骤名称',
	emp_id int not null comment '审核人',
	emp_name varchar(32) null comment '审核人名称',
	dept_name varchar(32) null comment '审核人部门名称',
	auditor_id int default 0 not null comment '具体操作人',
	auditor_name varchar(64) default '' not null comment '操作人名称',
	auditor_dept varchar(64) default '' not null comment '操作人部门',
	status int not null comment '当前处理状态 0待处理 9通过 -1驳回 0：处理中 -1：驳回 9：会签',
	content varchar(255) null comment '批复内容',
	is_read int default 0 not null comment '是否查看',
	is_real tinyint default 1 not null comment '审核人和操作人是否同一人',
	circle smallint(6) default 1 not null,
	beizhu text null comment '备注',
	concurrence int default 0 not null comment '并行查找解决字段， 部门 角色 指定 分组用',
	created_at timestamp default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP,
	updated_at timestamp default '2018-12-12 00:00:00' not null
)
comment '处理明细表' collate=utf8mb4_bin;

create index emp_id
	on proc (emp_id);

create index entry_id
	on proc (entry_id);

create index step_id
	on proc (process_id);

create index workflow_id
	on proc (flow_id);

create table process
(
	id int auto_increment
		primary key,
	flow_id int default 0 not null comment '流程id',
	process_name varchar(45) default '' not null comment '步骤名称',
	limit_time int default 0 not null comment '限定时间,单位秒',
	type varchar(32) default 'operation' not null comment '流程图显示操作框类型',
	icon varchar(64) default '' null comment '流程图显示图标',
	process_to varchar(255) default '' not null,
	style text null,
	style_color varchar(128) default '#78a300' not null,
	style_height smallint(6) default 30 not null,
	style_width smallint(6) default 120 not null,
	position_left varchar(128) default '100px' not null,
	position_top varchar(128) default '200px' not null,
	position smallint(6) default 1 not null comment '步骤位置',
	child_flow_id int default 0 not null comment '子流程id',
	child_after tinyint default 2 not null comment '子流程结束后 1.同时结束父流程 2.返回父流程',
	child_back_process int default 0 not null comment '子流程结束后返回父流程进程',
	description varchar(255) default '' not null comment '步骤描述',
	created_at timestamp null,
	updated_at timestamp null
)
comment '流程步骤' collate=utf8mb4_bin;

create table process_var
(
	id int auto_increment
		primary key,
	process_id int not null,
	flow_id int not null comment '流程id',
	expression_field varchar(45) not null comment '条件表达式字段名称'
)
comment '步骤判断变量记录' collate=utf8mb4_bin;

create index step_id
	on process_var (process_id);

create index workflow_id
	on process_var (flow_id);

create table template
(
	id int auto_increment
		primary key,
	template_name varchar(64) default '' not null,
	created_at timestamp default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP,
	updated_at timestamp default '2018-12-12 00:00:00' not null
)
comment '流程模板' collate=utf8mb4_bin;

create index template_name
	on template (template_name);

create table template_form
(
	id int auto_increment
		primary key,
	template_id int default 0 not null,
	field varchar(64) default '' not null comment '表单字段英文名',
	field_name varchar(64) default '' not null comment '表单字段中文名',
	field_type varchar(64) default '' not null comment '表单字段类型',
	field_value text null comment '表单字段值，select radio checkbox用',
	field_default_value text null comment '表单字段默认值',
	rules text null,
	sort int default 100 not null comment '排序',
	created_at timestamp default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP,
	updated_at timestamp default '2018-12-12 00:00:00' not null
)
comment '流程模板表单控件' collate=utf8mb4_bin;

create index template_id
	on template_form (template_id);

