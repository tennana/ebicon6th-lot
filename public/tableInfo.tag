<info>
	<p style="margin-top:1em">
		{ opts.user.displayName }=サン:Ebiconへようこそ。
		<span if={ !decision }>この画面での操作は即時反映されます。</span>
	</p>
	<p><a if={ !decision } onClick={ nameChange }>名前を変える</a>　<a if={ !decision } onClick={ deleteUser }>登録を削除する</a></p>
	<p if={ !decision }>
		<label class="fancy-checkbox">
			<input type="checkbox" checked={ isGM } onClick={ setGM }>
			<span>
				私はGMです
			</span>
		</label>
	</p>
	<div if={ !decision }>
	  <h2>選択中の卓</h2>
	  <p>第一希望：<br><a href="#{ oneTableID }_anchor" onclick={ anchorClick }>{ getTableName(oneTableID) }</a></p>
	  <p>第二希望：<br><a href="#{ twoTableID }_anchor" onclick={ anchorClick }>{ getTableName(twoTableID) }</a></p>
	</div>
	<div if={ decision }>
	  <h2>決定卓</h2>
	  <p><a href="#{ decision }_anchor" onclick={ anchorClick }><strong>{ getTableName(decision) }</strong></a></p>
	</div>
	<h2>卓情報</h2>
	<div each="{opts.info}">
	  <hr id="{ tableID }_anchor">
	  <h3>{master}卓 {system}</h3>
	  <div>
		<p>人数:{min}～{max}人 {level}</p>
		<p if={ item }>必須の持ち物:{item}</p>
		<p if={ url }><a href="{ url }" target="{ tableID }">参考URL(別タブ/PDF)</a></p>
	  </div>
	  <div if={ is_open }><pre>{body}</pre></div>
	  <div>
		<button type="button" style="width:100%" class="btn btn-empty" onClick={ toggleFunc } >
			<span class='{ is_open ? "icon-close":"icon-display2"}' />
			{ is_open ? "詳細を閉じる":"詳細を開く"}
		</button><br>
		<div class="selectBtn btn btn-empty btn-sm" if={ !decision } >
			<label class="fancy-checkbox">
				<input type="checkbox" checked={ parent.oneTableID == tableID } onClick={ setOne }>
				<span>
					第一希望
				</span>
			</label>
		</div>
		<div class="selectBtn btn btn-empty btn-sm" if={ !decision } >
			<label class="fancy-checkbox">
				<input type="checkbox" checked={ parent.twoTableID == tableID } onClick={ setTwo }>
				<span>
					第二希望
				</span>
			</label>
		</div>
	  </div>
	  <p><a href="#info_top_anchor">一番上へ戻る</a></p>
	</div>
	<style scoped>
		.btn.selectBtn { width: 49.3%; box-sizing:border-box; width: calc( 50% - 4px ); padding: 8px 10px;}
		.btn > .fancy-checkbox { margin-bottom:0px; }
	</style>

	<script>
		var tags = this;
		this.decision = null;

		opts.status.on("value",function(value){
			if(value.val()){
				tags.decision = value.val().decision;
				var selectTableId = value.val().selectTable;
				if(selectTableId && selectTableId.length > 0){
					tags.oneTableID = selectTableId[0] || this.oneTableID || "";
					tags.twoTableID = selectTableId[1] || this.twoTableID || "";
				} else {
					tags.oneTableID = "";
					tags.twoTableID = "";
				}
				tags.isGM = value.val().isGM;
			}
			if(!value.val() || !value.val().userName){
				opts.status.update({"photoUrl":tags.opts.user.photoURL,"userName":tags.opts.user.displayName || "名称未設定","providerData":tags.opts.user.providerData});
			} else {
				tags.update();
			}
		});

		opts.status.once("value",function(value){
			tags.oneTableID = tags.oneTableID || "";
			tags.twoTableID = tags.twoTableID || "";
			tags.update();
		});

		toggleFunc(e){
			e.item.is_open = !e.item.is_open;
			this.update();
			scrollTo(0,document.getElementById(e.item.tableID+"_anchor").offsetTop-66);
		}

		setOne(e){
			if(this.oneTableID == e.item.tableID){
				this.oneTableID = "";
			} else {
				this.oneTableID = e.item.tableID;
				if(this.oneTableID == this.twoTableID)
					this.twoTableID = "";
			}
			this.updateSelectId();
		}

		setTwo(e){
			if(this.twoTableID == e.item.tableID){
				this.twoTableID = "";
			} else {
				this.twoTableID = e.item.tableID;
				if(this.oneTableID == this.twoTableID)
					this.oneTableID = "";
			}
			this.updateSelectId();
		}

		setGM(e){
			opts.status.update({"isGM":e.target.checked,"photoUrl":tags.opts.user.photoURL,"userName":tags.opts.user.displayName,"providerData":tags.opts.user.providerData});
		}

		updateSelectId(){
			var selectId = [this.oneTableID || "",this.twoTableID || ""];
			opts.status.update({"selectTable":selectId,"photoUrl":tags.opts.user.photoURL,"userName":tags.opts.user.displayName,"providerData":tags.opts.user.providerData});
			opts.logger.push({"Name":opts.user.displayName,"time":new Date().toLocaleString(),"selectTable":selectId});
		}

		getTableName(tableID){
			if(tableID === undefined) return "読み込み中...";
			for( var i in opts.info){
				if(opts.info[i].tableID == tableID){
					return opts.info[i].master+"卓 "+opts.info[i].system;
				}
			}
			return "未選択";
		}

		nameChange(){
			setTimeout(function(){
				var name = prompt("名前を入力して下さい");
				if(name && name != tags.opts.user.displayName){
					tags.opts.user.updateProfile({
					  displayName:name
					}).then(function() {
						opts.status.update({"photoUrl":tags.opts.user.photoURL,"userName":tags.opts.user.displayName,"providerData":tags.opts.user.providerData});
					});
				}
			},100);
		}

		deleteUser(){
			if(confirm("削除すると卓分けの対象にならなくなります、OK？")){
				// 登録情報削除
				opts.status.remove();

				// 厳密には認証が直近でないと削除できない
				// そう、関係ないね
				this.opts.user.delete().then(function() {
					firebase.auth().signOut().then(function(){location.reload();});
				}, function(error) {
					firebase.auth().signOut().then(function(){location.reload();});
				});
			}
		}

		anchorClick(e){
			var target = document.getElementById(e.target.href.substr(e.target.href.indexOf("#")+1));
			if(target) scrollTo(0,target.offsetTop-66);
			return false;
		}
	</script>
</info>
