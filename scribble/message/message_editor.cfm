<!--- message_editor.cfm --->
<cfsilent>
	<cfset request.pageID = "">
	<cfset request.pageTitleDisplay = "JFAS System Administration">
</cfsilent>

<cfinclude template="#application.paths.includes#header.cfm">

<h2>User Alert Messages</h2>

<form name="frmMsgEditor" id="frmMsgEditor"><!--- MsgEditor = "Message Editor" --->
        <div id="div_SaveMsg">&nbsp;</div>
        
        <div id="div_MsgEditor">
			<center>
            <input type="hidden" name="hdn_MsgID" id="hdn_MsgID" value="" />
            <table border="0" cellspacing="1" cellpadding="1" style="font-family:Arial, Helvetica, sans-serif; font-size:14px; font-weight:normal;">
                  <tr>
                  		<td align="right" style="font-weight:normal;">Message Type</td>
                        <td align="left">
                        	<select name="sel_MsgType" id="sel_MsgType" 
                            		style="font-size:12px"
                                    onchange="f_onChange(this.name);">
                                <!---<option value="-1">Select / Create Message</option>--->
                            </select>
                            &nbsp;&nbsp;&nbsp;
                            <input type="text"
                            	   name="txt_MsgType" 
                                   id="txt_MsgType" 
                                   maxlength="20"
                                   size="20" 
                                   value=""
                                   onkeyup="f_onKeyUp(this.name)"
                                   />
                        </td>
                        <td align="left" style="font-size:9px; font-weight:bolder;">Only Capital alpha-numeric. Ex: WELCOME123</td>
                  </tr>

                  <tr>
                        <td align="right" style="font-weight:normal;">Message Status</td>
                        <td align="left">
                            <input type="radio" name="rbn_Status" id="rbn_Status" value="1" checked="checked"
                            	   onclick="f_onClick(this.name);"/>
                            <label for="rbn_Status" style="font-weight:normal;">On</label>
                            &nbsp;
                            <input type="radio" name="rbn_Status" id="rbn_Status" value="0" onclick="f_onClick(this.name);"/>  
                            <label for="rbn_Status" style="font-weight:normal;">Off</label>
                        </td>
                        <td>&nbsp;</td>
                  </tr>
                  <tr>
                  		<td align="right" style="font-weight:normal;">Comments</td>
                        <td align="left">
                        	<input type="text" 
                            	   name="txt_MsgComments" 
                                   id="txt_MsgComments" 
                                   size="53"/>
                        </td>
                        <td align="left" style="font-size:9px; font-weight:bolder;">Page name where message appear. Ex: AAPPs (Home Page)</td>
                  </tr>
                  <tr>
                  		<td align="right" valign="top" style="font-weight:normal;">Message</td>
                        <td align="left">
                        	<textarea name="txa_MsgText" 
                            		  rows="20" cols="53" 
                                      onkeydown="f_onKeyDown(this.name);" 
                                      onkeyup="f_onKeyUp(this.name);"
                                      ></textarea>
                        </td>
                        <td>&nbsp;</td>
                  </tr>
                  <tr>
                  		<td colspan="2" align="right" style="font-size:10px;">
                        	Characters left:
                        	<input align="right" 
                            	   readonly type="text" 
                                   style="border-style:hidden; border-color:transparent; font-weight:bold;" 
                                   name="txt_NumOfChar" 
                                   id="txt_NumOfChar"
                                   value=""
                                   size="4">(max 1000) 
                        </td>
                        <td>&nbsp;</td>
                  </tr>
            </table>
				  <cfoutput>
					<cfset vBtn = "style='font-family: Arial, Helvetica, sans-serif; "&
								  "font-size:11px; padding: none; margin-top: 10px; margin-bottom: 0px;' ">
                    <div class="buttons">
                          <button type="button" 
                          		  #vBtn# 
                          		  id="cbn_Save" 
                                  name="cbn_Save" 
                                  onClick="f_onClick(this.name);"
                                  >Save
                          </button>
                          &nbsp;
                          <!---<button type="button" 
                          		  #vBtn# 
                          		  id="cbn_Reset" 
                                  name="cbn_Reset" 
                                  onClick="f_onClick(this.name);"
                                  >Reset
                          </button>
                          &nbsp;--->
                          <button type="button" 
                          		  #vBtn# 
                          		  id="cbn_Delete" 
                                  name="cbn_Delete" 
                                  onClick="f_onClick(this.name);"
                                  >Delete
                          </button>
                          &nbsp;
                          <button type="button" 
                          		  #vBtn# 
                          		  id="cbn_Cancel" 
                                  name="cbn_Cancel" 
                                  onClick="location.href='admin_main.cfm'"
                                  >Cancel
                          </button>
                    </div><!--- end of div buttons--->
				  </cfoutput>
			</center>
        </div><!--- end of "div_MsgEditor" --->
        
</form>
<cfinclude template="#application.paths.includes#footer.cfm">
<cfinclude template="#application.paths.includes#message_editorJS.cfm">