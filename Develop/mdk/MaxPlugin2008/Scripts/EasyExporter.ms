-- 10.03.16 : v1.0
-- 10.03.17 : v2.0 / elu Export �ÿ� 'ground_' �̸��� ���Ե� ������Ʈ�� ������ Ground Expoer ����
-- 10.06.08 : v2.1 / Ư���ܾ�(a, x, m)�� ���Ե����� FileName ����� �ȳ����� ���� ����
macroScript EasyExporter
category:"MAIET" 
ButtonText:"EasyExporter"
ToolTip:"EasyExporter"
(
	exportFileType = "elu";
	typeString = exportFileType + "File(*." + exportFileType + ")|*"+ exportFileType +"|All|*.*|"
	if ( maxFilename != "" ) then
	(
		inFileName = (getFilenameFile maxFilename) + "." + exportFileType
		if (inFileName != "" ) then
		(
			f = getSaveFileName caption:"Export" filename:inFileName types:typeString
			if f != undefined then (
					exportFile(f)
			)
			
			-- ��ü ������Ʈ ��ȸ
			bIsGround = false
			for i = 1 to objects.count do (
				-- 'ground_' �� �̸��� ������ ������Ʈ�� �ִ°�
				if ( matchPattern objects[i].name pattern:"ground_*" == true ) then (
					bIsGround = true
					exit 
				)
			)
			
			-- ������Ʈ �̸��߿� ground_ �� �ְ�
			if bIsGround == true then (
				for i in utilityplugin.classes do (
					-- Ground Mesh Export Plugins �� �������� ����
					if i == Ground_Mesh_Export then  (
						UtilityPanel.OpenUtility Ground_Mesh_Export
					)
				)	
			)
		)
	)
)