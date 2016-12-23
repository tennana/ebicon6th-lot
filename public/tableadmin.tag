<admininfo>
	<p style="margin-top:1em">ようこそ、担当職員様。ご希望のファイルを選択して下さい。</p>
	<p> 総登録数は <b>{ status.length }</b> です。うちGMは { gmCount } です。 </p>
	<p><button class="btn btn-success" if={!status[0].decision} type="button" onclick={lot}>抽選する</button></p>
	<p><button class="btn btn-warning" type="button" onclick={enter}>確定する</button></p>
	<table class="table table-striped table-bordered table-hover">
		<thead>
			<tr>
				<th>卓名</th>
				<th>第一希望</th>
				<th>第二希望</th>
				<th>定数</th>
				<th>確定数:メンバー</th>
			</tr>
		</thead>
		<tbody>
			<tr each={opts.info}>
				<td>{getTableName(tableID)}</td>
				<td>{ tableMemberOne[tableID] }</td>
				<td>{ tableMemberTwo[tableID] }</td>
				<td>{min} - {max}</td>
				<td>{ member.length } : <span each={ memberUid , i in member }>{ getUserInfo(memberUid).userName || "名前不明" }、</span></td>
			</tr>
		</tbody>
	</table>
	<table class="table table-striped table-bordered table-hover">
		<thead>
			<tr>
				<th><label>名前<input type="radio" name="sort" value="userName" onclick={ sortFnc }></label></th>
				<th><label>GM<input type="radio" name="sort" value="isGM" onclick={ sortFnc }></label></th>
				<th><label>第一希望<input type="radio" name="sort" value="one" onclick={ sortFnc }></label></th>
				<th><label>第二希望<input type="radio" name="sort" value="two" onclick={ sortFnc }></label></th>
				<th><label style="display:inline-block">決定卓<input type="radio" name="sort" value="decision" onclick={ sortFnc }></label></th>
			</tr>
		</thead>
		<tbody>
		<tr>
			<td><input type="text" id="new_userName"></td>
			<td><input type="checkbox" id="new_isGM"></td>
			<td>
				<select id="new_one"><option value=""></option>
					<option each={opts.info} value="{tableID}">{getTableName(tableID)}</option>
				</select>
			</td>
			<td>
				<select id="new_two"><option value=""></option>
					<option each={opts.info} value="{tableID}">{getTableName(tableID)}</option>
				</select>
			</td>
			<td>
				<button type="button" class="btn" onclick={ newData }>追加する</button>
			</td>
		</tr>
		<tr each={status}>
			<td><i class="icon-close" onclick={ deleteData }/><img if={ photoUrl } src={ photoUrl } />{userName}</td>
			<td>{ "GM" : isGM }</td>
			<td>
				<span if={decision}>{ getTableName((selectTable && selectTable[0]) || "") }</span>
				<select if={!decision} data-type="0" onchange={ selectChange }><option value=""></option>
					<option each={parent.opts.info} value="{tableID}" selected={ tableID == parent.selectTable[0] }>{getTableName(tableID)}</option>
				</select>
			</td>
			<td>
				<span if={decision}>{ getTableName((selectTable && selectTable[1]) || "") }</span>
				<select if={!decision} data-type="1" onchange={ selectChange }><option value=""></option>
					<option each={parent.opts.info} value="{tableID}" selected={ tableID == parent.selectTable[1] }>{getTableName(tableID)}</option>
				</select>
			</td>
			<td if={decision}>{ getTableName(decision) }</td>
			<td if={!decision}>
				<select id="select_{uid}" class="select" onchange={ this.update }><option value="none"></option>
					<option each={parent.opts.info} value="{tableID}">{getTableName(tableID)}</option>
				</select>
			</td>
		</tr>
		</tbody>
	</table>
	<style scoped>
		.btn.selectBtn { width: 49.3%; box-sizing:border-box; width: calc( 50% - 4px ); padding: 8px 10px;}
		.btn > .fancy-checkbox { margin-bottom:0px; }
		.row > div { border: 1px black solid }
		.icon-close { font-size:larger;margin-right:1em }
	</style>

	<script>
		var tags = this;
		opts.status.on("value",function(value){
			var status = [];
			tags.gmCount = 0;
			tags.tableMemberOne = {};
			tags.tableMemberTwo = {};
			value.forEach(function(dataObj){
				var jsonObj = dataObj.val();
				jsonObj["uid"] = dataObj.getKey();
				status.push(jsonObj);
				if(jsonObj.isGM === true){
					tags.gmCount++;
				} else if(jsonObj.selectTable){
					if(jsonObj.selectTable[0]){
						tags.tableMemberOne[jsonObj.selectTable[0]] = ( tags.tableMemberOne[jsonObj.selectTable[0]] || 0)+1;
					}
					if(jsonObj.selectTable[1]){
						tags.tableMemberTwo[jsonObj.selectTable[1]] = ( tags.tableMemberOne[jsonObj.selectTable[1]] || 0)+1;
					}
				}
			});
			tags.status = status;
			tags.sortFnc();
			tags.update();
		});

		getTableName(tableID){
			if(!tableID) return "未選択";
			for( var i in opts.info){
				if(opts.info[i].tableID == tableID){
					return opts.info[i].master+"卓 "+opts.info[i].system;
				}
			}
			return "未選択";
		}

		getTableMax(tableID){
			if(!tableID) return "";
			for( var i in opts.info){
				if(opts.info[i].tableID == tableID){
					return opts.info[i].max;
				}
			}
			return "NaN";
		}

		sortFnc(e,status){
			if(e){
				tags.sortState = e.target.value;
			}
			var status = status || tags.status;
			tags.status = tags.status.sort(function(a,b){
				if(tags.sortState == "one"){
					var aVal = ((a.selectTable && a.selectTable[0]) || "");
					var bVal = ((b.selectTable && b.selectTable[0]) || "");
					if(aVal < bVal){
						return 1;
					}else if(aVal > bVal){
						return -1;
					} else {
						return 0;
					}
				} else if(tags.sortState == "two"){
					var aVal = ((a.selectTable && a.selectTable[1]) || "");
					var bVal = ((b.selectTable && b.selectTable[1]) || "");
					if(aVal < bVal){
						return 1;
					}else if(aVal > bVal){
						return -1;
					} else {
						return 0;
					}
				} else if(tags.sortState == "isGM"){
					return (b && b.isGM?1:0) - (a && a.isGM?1:0);
				} else {
					var aVal = a[tags.sortState] || "￮"+a.uid;
					var bVal = b[tags.sortState] || "￮"+a.uid;
					if(aVal < bVal){
						return -1;
					}else if(aVal > bVal){
						return 1;
					} else {
						return 0;
					}
				}
			});
			if(e){
				this.update();
			}
		}

		lot(){
			var tableInfo = opts.info;
			var vacancyTableMap = {};
			for(var i = 0;i < tableInfo.length;i++){
				vacancyTableMap[tableInfo[i].tableID] = tableInfo[i];
				tableInfo[i].member = [];
				tableInfo[i].tmpMember = [];
			}
			for(var priority=0; priority < 2 ;priority++){
				for(var memberNo = 0; memberNo < this.status.length;memberNo++){
					var memberData = this.status[memberNo];
					if(this["select_"+memberData.uid].value != "none"){
						// 決定済み
					} else if(!memberData.isGM && memberData.selectTable && memberData.selectTable[priority]){
						var selectID = memberData.selectTable[priority];
						if(vacancyTableMap[selectID]){
							vacancyTableMap[selectID].tmpMember.push(memberData.uid);
						}
					}
				}
				for(var currentTableID in vacancyTableMap){
					var tableInfo = vacancyTableMap[currentTableID];
					var memberNum = tableInfo.member.length;
					var tmpMember = tableInfo.tmpMember;
					// 定員以内でなければ定員以内になるまでランダムに除去
					while(tmpMember.length > 0 && tableInfo.max < memberNum + tmpMember.length){
						var faildID = randAry2(tmpMember);
						opts.logger.push({
							"Name":this.getUserInfo(faildID).userName,
							"uid":faildID,"time":new Date().toLocaleString(),
							"selectTable":this.getUserInfo(faildID).selectTable,
							"message":this.getTableName(tableInfo.tableID)+" : 落選"
						});
					}
					tableInfo.member = tableInfo.member.concat(tmpMember);
					if(tableInfo.max == tableInfo.member.length){
						// 確定卓
						delete vacancyTableMap[currentTableID];
					} else {
						tableInfo.shortfal = tableInfo.min - tableInfo.member.length;
					}
					for(var i = 0; i < tableInfo.member.length;i++){
						this["select_"+tableInfo.member[i]].value = currentTableID;
					}
					tableInfo.tmpMember = [];
				}
			}

			// 残っている人
			var noneOption = document.querySelectorAll(".select > option[value='none']:checked");
			var noneMember = [];
			for(var i = 0; i < noneOption.length;i++){
				var userInfo = this.getUserInfo(noneOption[i].parentNode.id.substr(7));
				if(!userInfo.isGM){
					noneMember.push(userInfo.uid);
					opts.logger.push({
						"Name":userInfo.userName,
						"uid":userInfo.uid,"time":new Date().toLocaleString(),
						"selectTable":userInfo.selectTable,
						"message":"希望外割り当ての対象"
					});
				}
			}
			if(noneMember.length > 0){
				var shortfalTable = [];
				var normalRamdomTable = [];
				for(var currentTableID in vacancyTableMap){
					var tableInfo = vacancyTableMap[currentTableID];
					if(tableInfo.shortfal > 0){
						shortfalTable.push(tableInfo);
						for(var i = tableInfo.max - tableInfo.min; i > 0 ;i--){
							normalRamdomTable.push(tableInfo.tableID);
						}
					} else {
						for(var i = tableInfo.max - tableInfo.member.length; i > 0 ;i--){
							normalRamdomTable.push(tableInfo.tableID);
						}
					}
				}
				shortfalTable = shortfalTable.sort(function(a,b){
					var sort = a.shortfal - b.shortfal;
					if(sort == 0){
						if(a.max == a.min){
							return -1;
						} else if(b.max == b.min){
							return 1;
						}
					}
					return sort;
				});
				while(noneMember.length > 0){
					var currentMemberUid = randAry2(noneMember);
					if(shortfalTable.length > 0){ // 不足卓を優先的に
						var currentTableID = shortfalTable[0].tableID;
						this["select_"+currentMemberUid].value = currentTableID;
						shortfalTable[0].shortfal--;
						if(shortfalTable[0].shortfal <= 0)
							shortfalTable.splice(0,1);
					} else { // 余った枠から適当に
						this["select_"+currentMemberUid].value = randAry2(normalRamdomTable);
					}
					opts.logger.push({
						"Name":this.getUserInfo(currentMemberUid).userName,
						"uid":currentMemberUid,"time":new Date().toLocaleString(),
						"message":"希望外割り当て: "+this.getTableName(this["select_"+currentMemberUid].value)
					});
				}
			}
			this.update();
		}

		this.on("update",function(){
			// 確定メンバーの再取得
			for(var i = 0; i < opts.info.length;i++){
				var currentTableInfo = opts.info[i];
				currentTableInfo.member = [];
				currentTableInfo.tmpMember = [];
				var options = document.querySelectorAll(".select > option[value='"+currentTableInfo.tableID+"']:checked");
				for(var j = 0; j < options.length;j++){
					currentTableInfo.member.push(options[j].parentNode.id.substr(7));
				}
			}
		});

		getUserInfo(uid){
			for(var memberNo = 0; memberNo < this.status.length;memberNo++){
				var memberData = this.status[memberNo];
				if(memberData.uid == uid){
					memberData.selectTable = memberData.selectTable || [];
memberData.userName  = memberData.userName || [];
					return memberData;
				}
			}
			return {};
		}

		enter(){
			var selects = document.getElementsByClassName("select");
			var updateData = {};
			for(var i=0; i < selects.length;i++){
				if(selects[i].value != "none") updateData[selects[i].id.substr(7)] = {"decision":selects[i].value};
			}
			for(var tableID in updateData){
				opts.status.child(tableID).update(updateData[tableID]);
			}
		}

		selectChange(e){
			var selectTable = e.item.selectTable || [];
			selectTable[parseInt(e.target.getAttribute("data-type"))] = e.target.value;
			opts.status.child(e.item.uid).update({"selectTable":selectTable});
		}

		newData(e){
			var updateData = {
				"userName":this.new_userName.value,
				"isGM":this.new_isGM.checked,
				"selectTable":[this.new_one.value,this.new_two.value]
			};
			opts.status.push(updateData);
			this.new_isGM.checked = false;
			this.new_userName.value = "";
			this.new_one.value = "";
			this.new_two.value = "";
		}

		deleteData(e){
			if(confirm("本当に？")){
				var updateData = {};
				updateData[e.item.uid] = null;
				opts.status.update(updateData);
			}
		}

		/** 
		* randAry2 【JavaScript】配列からランダムに値を取り出す - B-Teck! http://beatdjam.hatenablog.com/entry/2016/02/25/013702
		* 配列内からランダムに値を取得する
		* 取得した値は元の配列から削除される
		* @param {array} i_ary 配列
		* @return {object} 配列内の値
		*/
		function randAry2(i_ary){
		    //添字を全て取得
		    var aryKeys = Object.keys(i_ary);
		    //対象の添字を取得
		    var index = aryKeys[Math.floor(Math.random() * aryKeys.length)];
		    retVal = i_ary[index];
		    //引数が配列か判定する
		    if(i_ary instanceof Array){
		        i_ary.splice(index,1);
		    }else{
		        //配列でなければ連想配列と見做す
		        delete i_ary[index];
		    }
		    return retVal;
		}

	</script>
</admininfo>
