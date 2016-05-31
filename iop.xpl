<p:library version="1.0"
           xmlns:p="http://www.w3.org/ns/xproc"
           xmlns:iop="http://transpect.io/iop"
           xmlns:mox="http://www.xml-project.com/morgana"
           xmlns:mocc="http://www.xml-project.com/nasp/calabash-compatibility"
           xmlns:mod="http://www.xml-project.com/nasp/debug"
           xmlns:cx="http://xmlcalabash.com/ns/extensions">
   <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"
             use-when="p:system-property('p:product-name') = 'XML Calabash'"/>
   <p:import href="com.xml_project.morganaxproc.debugsteps.DebugSteps"
             mox:content-type="application/java-archive"
             use-when="p:system-property('p:product-name') = 'MorganaXProc' "/>
   <p:import href="com.xml_project.morganaxproc.calabash_compatibility.CalabashCompatibilityLibrary"
             mox:content-type="application/java-archive"
             use-when="p:system-property('p:product-name') = 'MorganaXProc' "/>
   <p:import href="http://transpect.io/iop/iop.xpl"/>
   <p:declare-step type="iop:message">
      <p:input port="source"
               primary="true"
               sequence="true"/>
      <p:output port="result"
                primary="true"
                sequence="true"/>
      <p:option name="message"
                required="true"/>
      <iop:message p:use-when="p:system-property('p:product-name') = 'XML Calabash'">
         <p:with-option name="message"
                        select="$message"/>
      </iop:message>
      <mod:report p:use-when="p:system-property('p:product-name') = 'MorganaXProc'">
         <p:with-option name="message"
                        select="$message"/>
      </mod:report>
   </p:declare-step>
   <p:declare-step type="iop:eval"
                   name="eval">
      <p:input port="pipeline"/>
      <p:input port="source"
               sequence="true"/>
      <p:input port="options"/>
      <p:output port="result"/>
      <p:option name="step"/>
      <p:option name="detailed"/>
      <iop:eval p:use-when="p:system-property('p:product-name') = 'XML Calabash'">
         <p:input port="pipeline">
            <p:pipe step="eval"
                    port="pipeline"/>
         </p:input>
         <p:input port="source">
            <p:pipe step="eval"
                    port="source"/>
         </p:input>
         <p:input port="options">
            <p:pipe step="eval"
                    port="options"/>
         </p:input>
         <!--
     		<p:with-option name="step" select="$step" />
     		-->
         <p:with-option name="detailed"
                        select="$detailed"/>
      </iop:eval>
      <mocc:eval p:use-when="p:system-property('p:product-name') = 'MorganaXProc'">
         <p:input port="pipeline">
            <p:pipe step="eval"
                    port="pipeline"/>
         </p:input>
         <p:input port="source">
            <p:pipe step="eval"
                    port="source"/>
         </p:input>
         <p:input port="options">
            <p:pipe step="eval"
                    port="options"/>
         </p:input>
         <p:with-option name="step"
                        select="$step"/>
         <p:with-option name="detailed"
                        select="$detailed"/>
      </mocc:eval>
   </p:declare-step>
</p:library>