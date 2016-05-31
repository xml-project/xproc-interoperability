<p:declare-step version="1.0"
					 name="interoperator"
					 xmlns:p="http://www.w3.org/ns/xproc"
					 xmlns:iop="http://transpect.io/iop"
					 xmlns:mox="http://www.xml-project.com/morgana"
					 xmlns:mod="http://www.xml-project.com/nasp/debug"
					 xmlns:cx="http://xmlcalabash.com/ns/extensions"
					 exclude-inline-prefixes="iop mox mod cx">
	
	<p:output port="status" />				 
	<p:option name="pipelineuri" required="true"/>
	<p:serialization port="status" indent="true" />
	
	<p:import href="com.xml_project.morganaxproc.debugsteps.DebugSteps" mox:content-type="application/java-archive" />
	
	<!-- IOP:MODIFY-PIPELINE -->
	<p:declare-step type="iop:modify-pipeline">
		<!-- Here is where the actual work is done -->
		<p:input port="source" />
		<p:output port="result" />
	
		<!-- make import of XML Calabash extension library conditional, if it is not already! -->		
		<p:add-attribute match="p:import[@href='http://xmlcalabash.com/extension/steps/library-1.0.xpl' and not(@use-when)]"
							  attribute-name="use-when"
							  attribute-value="p:system-property('p:product-name') = 'XML Calabash'" />
		
		<!-- add mox:depends-on for steps with cx:depends-on -->
		<p:viewport match="//*[@cx:depends-on and not(@mox:depends-on)]">
			<p:add-attribute match="/">
				<p:with-option name="attribute-name" select="'mox:depends-on'" />
				<p:with-option name="attribute-value" select="/*/@cx:depends-on" />
			</p:add-attribute>
		</p:viewport>
		
		<!-- rename cx:message to iop:message -->
		<p:rename match="cx:message" 
					 new-name="message"
					 new-prefix="iop"
					 new-namespace="http://transpect.io/iop"
					 xmlns:cx="http://xmlcalabash.com/ns/extensions" />
		
		<!-- rename cx:eval to iop:eval -->
		<p:rename match="cx:eval" 
					 new-name="eval"
					 new-prefix="iop"
					 new-namespace="http://transpect.io/iop"
					 xmlns:cx="http://xmlcalabash.com/ns/extensions" />
					 
		<!-- rename cx:zip to pxp:zip -->
		<p:rename match="cx:zip"
					 new-name="zip"
					 new-prefix="pxp"
					 new-namespace="http://exproc.org/proposed/steps"
					 xmlns:cx="http://xmlcalabash.com/ns/extensions" />

		
		<!-- Make sure, 'http://exproc.org/proposed/steps/file' is used as namespace for steps in http://exproc.org/proposed/steps/file 
			  This is necessary, because XML Calabash uses both namespaces for EXProc.org's file utility library
		-->
		<p:namespace-rename from="http://xmlcalabash.com/ns/extensions/fileutils" to="http://exproc.org/proposed/steps/file" apply-to="elements" />
		
		
		<!-- Now import pipelines if needed -->
		<!-- First: "http://transpect.io/iop/iop.xpl" -->
		<p:choose>
			<p:when test="//iop:* and not(//p:import/@href='http://transpect.io/iop/iop.xpl')">
				<p:insert match="p:import[last()]" position="after">
					<p:input port="insertion">
						<p:inline>
							<p:import href="http://transpect.io/iop/iop.xpl" />
						</p:inline>
					</p:input>
				</p:insert>
			</p:when>
			<p:otherwise>
				<p:identity />
			</p:otherwise>
		</p:choose>
		
		<!-- Second: http://exproc.org/proposed/steps/os -->
		<p:choose>
			<p:when test="//pos:* and not(//p:import/@href='http://exproc.org/proposed/steps/os')">
				<p:insert match="p:import[last()]" position="after">
					<p:input port="insertion">
						<p:inline>
							<p:import href="http://exproc.org/proposed/steps/os" use-when="p:system-property('p:product-name') = 'MorganaXProc'" />
						</p:inline>
					</p:input>
				</p:insert>
			</p:when>
			<p:otherwise>
				<p:identity />
			</p:otherwise>
		</p:choose>
		
		<!-- Third: http://exproc.org/proposed/steps/file -->
		<p:choose>
			<p:when test="//pxf:* and not(//p:import/@href='http://exproc.org/proposed/steps/file')">
				<p:insert match="p:import[last()]" position="after">
					<p:input port="insertion">
						<p:inline>
							<p:import href="http://exproc.org/proposed/steps/file" use-when="p:system-property('p:product-name') = 'MorganaXProc'" />
						</p:inline>
					</p:input>
				</p:insert>
			</p:when>
			<p:otherwise>
				<p:identity />
			</p:otherwise>
		</p:choose>

		<!-- Fourth: http://exproc.org/proposed/steps -->
		<p:choose>
			<p:when test="//pxp:* and not(//p:import/@href='http://exproc.org/proposed/steps')">
				<p:insert match="p:import[last()]" position="after">
					<p:input port="insertion">
						<p:inline>
							<p:import href="http://exproc.org/proposed/steps" use-when="p:system-property('p:product-name') = 'MorganaXProc'" />
						</p:inline>
					</p:input>
				</p:insert>
			</p:when>
			<p:otherwise>
				<p:identity />
			</p:otherwise>
		</p:choose>


	</p:declare-step>
	
	<!-- IOP:PROCESS-PIPELINE -->
	<p:declare-step type="iop:process-pipeline">
		<p:output port="status" />
		<p:option name="pipelineuri" required="true" />
		
		<p:try>
			<p:group>
				<mod:report>
					<p:input port="source"> <p:empty /></p:input>
					<p:with-option name="message" select="concat('Processing: ', $pipelineuri)" />
				</mod:report>
				
				<p:load name="pipeline-loader">
					<p:with-option name="href" select="$pipelineuri" />
				</p:load>
				
				<!-- handle imports recursivly -->
				<p:for-each>
					<p:iteration-source select="/p:declare-step/p:import | p:pipeline/p:import | p:library/p:import">
						<p:pipe step="pipeline-loader" port="result" />
					</p:iteration-source>
					<p:variable name="thePipelineUri" select="resolve-uri(/p:import/@href, base-uri())" />
					<p:choose>
						<p:when test="not(starts-with($thePipelineUri,'http://xmlcalabash.com')) and
										  not(starts-with($thePipelineUri,'http://exproc.org')) and
										  compare($thePipelineUri,'http://transpect.io/iop/iop.xpl') != 0">
							<iop:process-pipeline>
								<p:with-option name="pipelineuri" select="$thePipelineUri" />
							</iop:process-pipeline>					
						</p:when>
						<p:otherwise>
							<p:identity>
								<p:input port="source">
									<p:inline>
										<dummy />
									</p:inline>
								</p:input>
							</p:identity>
						</p:otherwise>
					</p:choose>
				</p:for-each>
				<p:sink />

				<!-- change the pipeline -->
				<iop:modify-pipeline>
					<p:input port="source">
						<p:pipe step="pipeline-loader" port="result"/>
					</p:input>
				</iop:modify-pipeline>
				
				<!-- now store it -->
				<p:store indent="true">				
					<p:with-option name="href" select="./base-uri()" />
				</p:store>
				
				<!-- Successful: Create result -->
				<p:identity>
					<p:input port="source">
						<p:inline>
							<done />
						</p:inline>
					</p:input>
				</p:identity>
			</p:group>
			<p:catch name="catcher">
				<p:identity>
					<p:input port="source">
						<p:pipe step="catcher" port="error" />
					</p:input>
				</p:identity>
				<mod:report message="error on import" write-source="true" />
			</p:catch>
		</p:try>
	</p:declare-step>
						 
	
	<!-- Main subpipeline -->
	<iop:process-pipeline>
		<p:with-option name="pipelineuri" select="$pipelineuri" />
	</iop:process-pipeline>
</p:declare-step>