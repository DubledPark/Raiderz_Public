<?xml version = "1.0" ?>
<xsl:stylesheet version = "1.0" xmlns:xsl = "http://www.w3.org/1999/XSL/Transform">

	<xsl:template match = "/">
   		<html>	
   		<head>
		   	<style type='text/css'>
				td {  font-family: verdana; font-size:11; color: #000000;}
   			</style>
			<script type="text/javascript">
			function ChildVisSwap(Tbl)
			{
				var child = Tbl.getElementsByTagName("DIV")
				if( child[0].style.visibility != "hidden" ) {
					child[0].style.visibility="hidden";
					child[0].style.height="0"
				} else {
					child[0].style.visibility=""
					child[0].style.height=""
				}
			}
			</script>
		</head>
   		<body bgcolor="white">
   			<xsl:apply-templates select="maiet"/>
		</body>   			
   		</html>
	</xsl:template>

	<xsl:template match="maiet">
		<!--
		<table>
			<xsl:for-each select="Effect">
				<xsl:sort select="@Name"/>
				<tr><td> <xsl:value-of select="@Name"/> </td></tr>
			</xsl:for-each> 
		</table>
		<br/>
		-->
		<xsl:apply-templates select="Effect">
			<xsl:sort select="@Name"/>
		</xsl:apply-templates>
		
	</xsl:template>
	
	<!-- Effect template-->
	<xsl:template match="Effect">
	
	<table onclick="ChildVisSwap(this)" style="height:0" cellpadding="1" bgcolor="black">
	<tr bgcolor="white"><td>
		<center><b><xsl:value-of select="@Name" /></b></center><br/>		
		<div height="100" style="visibility:hidden;height:0">
			<xsl:apply-templates select="Sound"/>
			<xsl:apply-templates select="Model"/>
			<xsl:apply-templates select="Camera"/>
			<xsl:apply-templates select="PostEffect"/>
			<xsl:apply-templates select="DecalEffect"/>
		</div>
	</td></tr>
	</table>
	<br/>
	</xsl:template>
	
	
	<!-- Sound template -->
	<xsl:template match="Sound">
	<font face="verdana" size="3" color="#FF0000" >Sound Info</font>
	<table border='0' cellspacing='0' cellpadding="0" width="500">
	<tr><td width="200">FileName</td><td> <font size="2"><B><xsl:value-of select="@FileName" /></B></font> </td></tr> <!-- 파일이름 -->
	<tr bgcolor='black' height='1' ><td></td><td></td></tr>
	<tr><td> BoneName </td> <td><xsl:value-of select="@BoneName" /> </td></tr>								<!--  본 이름(내용이 있을경우 우선적으로 처리) -->
	<tr bgcolor='black' height='1' ><td></td><td></td></tr>
	<tr><td> DurationTime</td><td><xsl:value-of select="@DurationTime" /> </td></tr> 						<!--지속 시간 -->
	<tr bgcolor='black' height='1' ><td></td><td></td></tr>
	</table>	
	<br/>
	</xsl:template>
	
	<!-- Model template -->
	<xsl:template match="Model">
	
	<font face="verdana" size="3" >Model Info</font>
	<table border='0' cellspacing='0' cellpadding="0" width="500">
	<tr><td width="200">FileName</td><td> <font size="2"><B><xsl:value-of select="@FileName" /></B></font> </td></tr>
	<tr bgcolor='black' height='1' ><td></td><td></td></tr>
	
	<tr><td>BoneName</td><td> <xsl:value-of select="@BoneName" /> </td></tr>
	<tr bgcolor='black' height='1' ><td></td><td></td></tr>
	
	<tr><td> Follow(true)</td> <td><xsl:value-of select="@Follow" /> </td></tr>						<!--           : 본을 따라가기 (본이 없으면 원점 따라가기, 발사체는 특수한 상황이어서 꼭!! "false"이어야 합니다.) -->
	<tr bgcolor='black' height='1' ><td></td><td></td></tr>
	
	<tr><td> X, Y, Z </td> <td><xsl:value-of select="@X" /> , <xsl:value-of select="@Y" /> , <xsl:value-of select="@Z" /> </td></tr>								<!--                  : 로컬 좌표 -->
	<tr bgcolor='black' height='1' ><td></td><td></td></tr>
	
	<tr><td> ImmediatlyDelete(flase)</td><td><xsl:value-of select="@ImmediatlyDelete" /> </td></tr> 	<!-- : 즉시 삭제 -->
	<tr bgcolor='black' height='1' ><td></td><td></td></tr>
	
	<tr><td> TerrainPos(flase)</td>	<td><xsl:value-of select="@TerrainPos" /> </td></tr>			<!-- : 지형 위치에 설정 -->
	<tr bgcolor='black' height='1' ><td></td><td></td></tr>
	
	<tr><td> TerrainAlign(flase)</td><td><xsl:value-of select="@TerrainAlign" /> </td></tr> <!--   : 지형 위치와 지형 노말값으로 설정. TerrainPos보다 순위가 높음 -->
	<tr bgcolor='black' height='1' ><td></td><td></td></tr>
	
	<tr><td> Align(false)</td> <td><xsl:value-of select="@Align" /> </td></tr><!--          : 본이 있는 경우 본의 방향에 영향이 있는지에 대한 설정 - (false는 무시 안함, true 무시 함) -->
	<tr bgcolor='black' height='1' ><td></td><td></td></tr>
	
	<tr><td> AutoScale(false)</td><td><xsl:value-of select="@AutoScale" /> </td></tr> <!--       : 본 또는 Actor에 스케일이 있는 경우 스케일값이 적용이 되는지에 대한 설정 (true - 스케일 적용, false - 스케일 무시) -->
	<tr bgcolor='black' height='1' ><td></td><td></td></tr>
	
	<tr><td> Scale(1.0f)</td><td><xsl:value-of select="@Scale" /> </td></tr> <!--          : 이펙트 스케일 값이다. AutoScale에 따라 최종 스케일 값이 다르게 나올 수 있다. -->
	<tr bgcolor='black' height='1' ><td></td><td></td></tr>
	
	<tr><td> DurationTime </td> <td><xsl:value-of select="@DurationTime" /> </td></tr>       <!-- : 지속 시간 -->
	<tr bgcolor='black' height='1' ><td></td><td></td></tr>
	
	<tr><td> StartVisibilityTime(0.0f)</td><td><xsl:value-of select="@StartVisibilityTime" /> </td></tr> <!--: 시작시 나타나는 시간 -->
	<tr bgcolor='black' height='1' ><td></td><td></td></tr>
	
	<tr><td> EndVisibilityTime(0.0f) </td><td><xsl:value-of select="@EndVisibilityTime" /> </td></tr> <!-- : 끝날때 사라지는 시간 -->
	<tr bgcolor='black' height='1' ><td></td><td></td></tr>
     
	</table>	
	<br/>
	</xsl:template>
	
	<!-- Camera template -->
	<xsl:template match="Camera">
	
	<font face="verdana" size="3" >Camera Info</font>
	<table border='0' cellspacing='0' cellpadding="1" width="500">
	<tr><td width="200">FileName</td><td> <font size="2"><B><xsl:value-of select="@FileName" /></B></font> </td></tr>
	<tr bgcolor='black' height='1' ><td></td><td></td></tr>
	
	<tr><td width="200">Distance</td><td> <font size="2"><B><xsl:value-of select="@Distance" /></B></font> </td></tr><!--거리(사운드 범위)-->
	<tr bgcolor='black' height='1' ><td></td><td></td></tr>
	
	<tr><td> DurationTime</td> <td><xsl:value-of select="@DurationTime" /> </td></tr><!--           지속 시간 -->
	<tr bgcolor='black' height='1' ><td></td><td></td></tr>
    
	</table>	
	</xsl:template>

	<!-- PostEffect template -->
	<xsl:template match="PostEffect">
	
	<font face="verdana" size="3" >PostEffect Info</font>
	<table border='0' cellspacing='0' cellpadding="1" width="500">
	<tr><td width="200">Type</td><td> <font size="2"><B><xsl:value-of select="@Type" /></B></font> </td></tr>
	<tr bgcolor='black' height='1' ><td></td><td></td></tr>
	
	<tr><td >PlayTime</td><td> <font size="2"><B><xsl:value-of select="@PlayTime" /></B></font> </td></tr>
	<tr bgcolor='black' height='1' ><td></td><td></td></tr>
	
	<tr><td> ScatTime</td> <td><xsl:value-of select="@ScatTime" /> </td></tr>
	<tr bgcolor='black' height='1' ><td></td><td></td></tr>
	
	<tr><td> Speed</td> <td><xsl:value-of select="@Speed" /> </td></tr>
	<tr bgcolor='black' height='1' ><td></td><td></td></tr>
	
    <tr><td> Distance</td> <td><xsl:value-of select="@Distance" /> </td></tr>
	<tr bgcolor='black' height='1' ><td></td><td></td></tr>
	
	<tr><td> ScarFactorType</td> <td><xsl:value-of select="@ScarFactorType" /> </td></tr>
	<tr bgcolor='black' height='1' ><td></td><td></td></tr>
	
	</table>	
	</xsl:template>
	
	<!-- DecalEffect template -->
	<xsl:template match="DecalEffect">
	
	<font face="verdana" size="3" >DecalEffect Info</font>
	<table border='0' cellspacing='0' cellpadding="1" width="500">
	<tr><td width="200">Type</td><td> <font size="2"><B><xsl:value-of select="@Type" /></B></font> </td></tr> <!-- 데칼 타입(projection - 마법진, polygon - 탄흔, 발자국, 혈흔) -->
	<tr bgcolor='black' height='1' ><td></td><td></td></tr>
	
	<tr><td >BoneName</td><td> <font size="2"><B><xsl:value-of select="@BoneName" /></B></font> </td></tr> <!-- 본 이름(내용이 있을경우 우선적으로 처리) -->
	<tr bgcolor='black' height='1' ><td></td><td></td></tr>
	
	<tr><td> FileName</td> <td><xsl:value-of select="@FileName" /> </td></tr> <!-- 데칼 텍스쳐 파일이름 -->
	<tr bgcolor='black' height='1' ><td></td><td></td></tr>
	
	<tr><td>  Follow(false) </td> <td><xsl:value-of select="@Follow" /> </td></tr> <!-- 본을 따라가기 (본이 없으면 원점 따라가기) -->
	<tr bgcolor='black' height='1' ><td></td><td></td></tr>
	
	<tr><td> Size</td> <td><xsl:value-of select="@Size" /> </td></tr> <!-- 데칼 크기(반지름, 자동으로 구해지는 크기이면 0으로 해야 합니다. 예: 마법진) -->
	<tr bgcolor='black' height='1' ><td></td><td></td></tr>
	
    <tr><td> DurationTime</td> <td><xsl:value-of select="@DurationTime" /> </td></tr> <!-- 지속 시간 -->
	<tr bgcolor='black' height='1' ><td></td><td></td></tr>
	
	<tr><td> StartVisibilityTime</td> <td><xsl:value-of select="@StartVisibilityTime" /> </td></tr> <!-- 시작시 나타나는 시간 -->
	<tr bgcolor='black' height='1' ><td></td><td></td></tr>
	
	<tr><td> EndVisibilityTime</td> <td><xsl:value-of select="@EndVisibilityTime" /> </td></tr> <!-- 끝날때 사라지는 시간 -->
	<tr bgcolor='black' height='1' ><td></td><td></td></tr>
		
	</table>	
	</xsl:template>
   
</xsl:stylesheet>