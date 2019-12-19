var ofmeet = (function(of)
{
    let domain, server, workgroup, hosted, plugins, conversation;

    const fpDiv = document.querySelector("fastpath-chat");

    if (fpDiv)
    {
        domain = fpDiv.getAttribute("domain");
        server = fpDiv.getAttribute("server");
        workgroup = fpDiv.getAttribute("workgroup");
        hosted = fpDiv.getAttribute("hosted");
        plugins = fpDiv.getAttribute("plugins");
        conversation = fpDiv.getAttribute("conversation");
    }

    if (!domain) domain = location.hostname;
    if (!server) server = location.host;
    if (!hosted) hosted = "https://igniterealtime.github.io/webmeet";
    if (!workgroup) workgroup = "demo";
    if (!plugins) plugins = "webmeet,jitsimeet";
    if (!conversation) conversation = "false";

    const fastpath = workgroup + '@workgroup.' + domain;
    const roomJid = workgroup + '@conference.' + domain;
    const boshUri = 'https://' + server + '/http-bind/';
    const wsUri = 'wss://' + server + '/ws/';

    const welcome = ["Welcome to Fastpath. How can we help you?", "You can type !help anytime for list of commands"]

    var nickColors = {}, avatars = {}, videoRecorder = null, _converse = null, chatButton, opened = false;

    window.addEventListener("load", function()
    {
        chatButton = document.getElementById("chatbutton");

        chatButton.addEventListener("click", function (e)
        {
            console.debug("chatButton clicked");
            chatButton.style.visibility = "hidden";

            doConverse()
        });
    });

    //-------------------------------------------------------
    //
    //  Functions
    //
    //-------------------------------------------------------

    function doConverse(credentials)
    {
        document.getElementById("chatloader").style.visibility = "visible";

        if (!_converse)
        {
            console.debug('converse plugins', plugins);

            if (plugins.indexOf("webmeet") > -1) setupWebMeet();
            if (plugins.indexOf("audioconf") > -1) setupAudioConf();
            if (plugins.indexOf("jitsimeet") > -1) setupJitsiMeet();


            const config = {
                auto_login: true,
                theme: 'concord',
                allow_non_roster_messaging: true,
                auto_join_on_invite: true,
                authentication: 'anonymous',
                jid: domain,
                nickname: getNick(),
                auto_away: 300,
                auto_reconnect: true,
                debug: false,
                singleton: true,
                sticky_controlbox: false,
                muc_show_join_leave: true,
                muc_show_join_leave_status: false,
                bosh_service_url: boshUri,
                websocket_url: wsUri,
                message_archiving: 'always',
                locales_url: hosted + '/widget/locale/{{{locale}}}/LC_MESSAGES/converse.json',
                sounds_path: hosted + '/widget/sounds/',
                whitelisted_plugins: plugins.split(",")
            };

            console.debug('converse config', config);
            converse.initialize(config);
        }
        else {
            openFastPath();
        }
    }

    function openFastPath()
    {
        getFastPathStatus(function(open)
        {
            console.debug('fastpath opened', open);

            if (open)
            {
                if (conversation == "true")
                {
                    _converse.api.chats.open(fastpath);
                }
                else {
                    joinWorkgroup({});
                }

            }
            else {
                _converse.api.rooms.open(roomJid, {nick: getNick()});
            }
        });
    }

    function joinWorkgroup(form)
    {
        let iq = converse.env.$iq({to: fastpath, type: 'set'}).c('join-queue', {xmlns: 'http://jabber.org/protocol/workgroup'});
        iq.c('queue-notifications').up();
        iq.c('x', {xmlns: 'jabber:x:data', type: 'submit'});

        const items = Object.getOwnPropertyNames(form)

        for (let i=0; i< items.length; i++)
        {
            iq.c('field', {var: items[i]}).c('value').t(form[items[i]]).up().up();
        }

        iq.up();

        _converse.connection.sendIQ(iq, function (res)
        {
            console.debug('join workgroup ok', res);

        }, function (err) {
            console.error('join workgroup error', err);
            document.getElementById("chatloader").style.visibility = "hidden";
        });
    }

    function getFastPathStatus(callback)
    {
        const iq = converse.env.$iq({type: 'get', to: fastpath}).c('query', {xmlns: 'http://jabber.org/protocol/disco#info'});

        _converse.connection.sendIQ(iq, function(resp)
        {
            console.debug("getFastPathStatus", resp);

            const fields = resp.querySelectorAll('field');

            for (var i=0; i<fields.length; i++)
            {
                if (fields[i].getAttribute("var") == "workgroup#online")
                {
                     opened = fields[i].querySelector('value').innerHTML == "OPEN";
                }
            }

            callback(opened);

        }, function(err) {
            console.error("fastpath error", err);
            callback(false);
        });
    }

    function getNick()
    {
        if (!window.localStorage["webmeet.nick"]) return undefined;
        else {
            return JSON.parse(window.localStorage["webmeet.nick"]);
        }
    }

    function setNick(nick)
    {
        if (!nick) return;
        window.localStorage["webmeet.nick"] = JSON.stringify(nick);
    }

    function setupJitsiMeet()
    {
        var Strophe = converse.env.Strophe, dayjs = converse.env.dayjs;
        var MeetDialog = null, meetDialog = null;

        converse.plugins.add("jitsimeet", {
            dependencies: [],

            initialize: function () {
                _converse = this._converse;

                _converse.api.settings.update({
                    jitsimeet_modal: false,
                    jitsimeet_url: 'https://meet.jit.si',
                    jitsimeet_confirm: "Meeting?",
                    jitsimeet_invitation: 'Please join meeting in room at'
                });

                _converse.on('message', function (data)
                {
                    var chatbox = data.chatbox;
                    var bodyElement = data.stanza.querySelector('body');

                    if (bodyElement && _converse.shouldNotifyOfMessage(data.stanza))
                    {
                        var body = bodyElement.innerHTML;
                        var url = _converse.api.settings.get("jitsimeet_url");
                        var pos = body.indexOf(url + "/");

                        if (pos > -1)
                        {
                            var room = body.substring(pos + url.length + 1);
                            var label = pos > 0 ? body.substring(0, pos) : _converse.api.settings.get("jitsimeet_invitation");
                            var from = chatbox.getDisplayName().trim();
                            var avatar = _converse.DEFAULT_IMAGE;

                            if (data.chatbox.vcard.attributes.image) avatar = data.chatbox.vcard.attributes.image;

                            var prompt = new Notification(from,
                            {
                                'body': label + " " + room,
                                'lang': _converse.locale,
                                'icon': avatar,
                                'requireInteraction': true
                            });

                            prompt.onclick = function(event)
                            {
                                event.preventDefault();

                                var box_jid = Strophe.getBareJidFromJid(chatbox.get("from") || chatbox.get("jid"));
                                var view = _converse.chatboxviews.get(box_jid);

                                if (view)
                                {
                                    openChatbox(view);
                                    doLocalVideo(view, room, url + "/" + room, label);
                                }
                            }
                        }
                    }
                });

                _converse.api.listen.on('renderToolbar', function(view)
                {
                    if (view.model.get("type") == "chatroom")
                    {
                        of.view = view;
                        var id = view.model.get("box_id");

                        var jitsiMeet = addToolbarItem(view, id, "pade-jitsimeet-" + id, '<a class="fas fa-video" title="Jitsi Meet"></a>');

                        jitsiMeet.addEventListener('click', function(evt)
                        {
                            evt.stopPropagation();

                            var jitsiConfirm = _converse.api.settings.get("jitsimeet_confirm");

                            if (confirm(jitsiConfirm))
                            {
                                doVideo(view);
                            }

                        }, false);
                    }
                });


                MeetDialog = _converse.BootstrapModal.extend({
                    initialize() {
                        _converse.BootstrapModal.prototype.initialize.apply(this, arguments);
                        this.model.on('change', this.render, this);
                    },
                    toHTML() {
                      var view = this.model.get("view");
                      var label = this.model.get("label");
                      var room = this.model.get("room");
                      var url = this.model.get("url");

                      return '<div class="modal" id="myModal"> <div class="modal-dialog modal-lg"> <div class="modal-content">' +
                             '<div class="modal-header">' +
                             '  <h4 class="modal-title">' + label + ' ' + room + '</h4>' +
                             '</div>' +
                             '<div style="text-align: center;" class="modal-body"><iframe src="' + url + '" id="jitsimeet" allow="microphone; camera;" frameborder="0" seamless="seamless" allowfullscreen="true" scrolling="no" style="z-index: 2147483647;width:640px;height:480px;display: inline-block"></iframe></div>' +
                             '<div class="modal-footer"> <button type="button" class="btn btn-danger btn-terminate" data-dismiss="modal">Close</button> </div>' +
                             '</div> </div> </div>';
                    },
                    events: {
                        "click .btn-terminate": "terminateCall"
                    },

                    terminateCall() {
                        this.el.querySelector('.modal-body').innerHTML = "about:blank"
                    }
                });

                console.log("jitsimeet plugin is ready");
            },

            overrides: {

                MessageView: {

                    renderChatMessage: async function renderChatMessage()
                    {
                        var dataJid = Strophe.getBareJidFromJid(this.model.get("from") || this.model.get("jid"));
                        var body = this.model.get('message');
                        var url = _converse.api.settings.get("jitsimeet_url");
                        var pos = body.indexOf(url + "/");

                        if (pos > -1)
                        {
                            var link_room = body.substring(pos + url.length + 1);
                            var link_id = link_room + "-" + Math.random().toString(36).substr(2,9);
                            var link_label = pos > 0 ? body.substring(0, pos) : _converse.api.settings.get("jitsimeet_invitation");
                            var link_content = '<a data-jid="' + dataJid + '" id="' + link_id + '" href="#">' + link_label + " " + link_room + '</a>';

                            setupContentHandler(this, link_room, link_content, link_id, link_label);
                        }
                        else {
                            await this.__super__.renderChatMessage.apply(this, arguments);
                        }
                    }

                }
            }
        });

        var setupContentHandler = function(chat, avRoom, content, linkId, linkLabel)
        {
            var dayjs_time = dayjs(chat.model.get('time'));
            var pretty_time = dayjs_time.format(_converse.time_format);
            var time = dayjs_time.format();

            var msg_content = document.createElement("div");
            msg_content.setAttribute("class", "message chat-msg groupchat");
            msg_content.setAttribute("data-isodate", time);

            if (chat.model.vcard)
            {
                msg_content.innerHTML = '<img class="avatar" src="data:image/png;base64,' + chat.model.vcard.attributes.image + '" style="width: 36px; width: 36px; height: 100%; margin-right: 10px;"/> <div class="chat-msg-content"> <span class="chat-msg-heading"> <span class="chat-msg-author">' + chat.model.getDisplayName() + '</span> <span class="chat-msg-time">' + pretty_time + '</span> </span> <span class="chat-msg-text">' + content + '</span> <div class="chat-msg-media"></div> </div>';
                chat.replaceElement(msg_content);
            }

            if (avRoom && linkId)
            {
                setTimeout(function()
                {
                    if (document.getElementById(linkId)) document.getElementById(linkId).onclick = function(evt)
                    {
                        var url = _converse.api.settings.get("jitsimeet_url") + '/' + avRoom;
                        var dataJid = evt.target.getAttribute("data-jid");
                        var view = _converse.chatboxviews.get(dataJid);

                        if (view) doLocalVideo(view, avRoom, url, linkLabel);
                    }
                }, 1000);
            }
        }


        var doVideo = function doVideo(view)
        {
            var room = Strophe.getNodeFromJid(view.model.attributes.jid).toLowerCase() + "-" + Math.random().toString(36).substr(2,9);
            var url = _converse.api.settings.get("jitsimeet_url") + '/' + room;

            console.debug("doVideo", room, url, view);

            var label = _converse.api.settings.get("jitsimeet_invitation");
            view.model.sendMessage(label + ' ' + url);

            doLocalVideo(view, room, url, label);
        }

        var doLocalVideo = function doLocalVideo(view, room, url, label)
        {
            console.debug("doLocalVideo", view, room, url, label);

            var modal = _converse.api.settings.get("jitsimeet_modal") == true;

            if (modal)
            {
                meetDialog = new MeetDialog({'model': new converse.env.Backbone.Model({url: url, view: view, label: label, room: room}) });
                meetDialog.show();
            }
            else {

                var div = view.el.querySelector(".box-flyout");

                if (div)
                {
                    div.innerHTML = '<iframe src="' + url + '" id="jitsimeet" allow="microphone; camera;" frameborder="0" seamless="seamless" allowfullscreen="true" scrolling="no" style="z-index: 2147483647;width:100%;height:-webkit-fill-available;height:-moz-available;"></iframe>';

                    var jitsiDiv = div.querySelector('#jitsimeet');
                    var firstTime = true;

                    jitsiDiv.addEventListener("load", function ()
                    {
                        console.debug("doVideo - load", this);

                        if (!firstTime) // meeting closed and root url is loaded
                        {
                            view.close();
                            //openChatbox(view);
                        }

                        if (firstTime) firstTime = false;   // ignore when jitsi-meet room url is loaded

                    });
                }
            }
        }

        var openChatbox = function openChatbox(view)
        {
            let jid = view.model.get("jid");
            let type = view.model.get("type");

            if (jid)
            {
                if (type == "chatbox") _converse.api.chats.open(jid);
                else
                if (type == "chatroom") _converse.api.rooms.open(jid);
            }
        }
    }


    function setupWebMeet()
    {
        converse.plugins.add("webmeet", {
            dependencies: [],

            initialize: function () {
                _converse = this._converse;

                var QRCodeDialog = _converse.BootstrapModal.extend({
                    initialize() {
                        _converse.BootstrapModal.prototype.initialize.apply(this, arguments);
                        this.model.on('change', this.render, this);
                    },
                    toHTML() {
                      var title = this.model.get("title");
                      return '<div class="modal" id="myModal"> <div class="modal-dialog"> <div class="modal-content">' +
                             '<div class="modal-header"><h1 class="modal-title">' + title + '</h1><button type="button" class="close" data-dismiss="modal">&times;</button></div>' +
                             '<div class="modal-body"></div>' +
                             '<div class="modal-status">Please scan the QR code with your IRMA app</div>' +
                             '<div class="modal-footer"><button type="button" class="btn btn-danger" data-dismiss="modal">Cancel</button></div>' +
                             '</div> </div> </div>';
                    },
                    afterRender() {
                        var that = this;
                        var qrcode = this.model.get("qrcode");

                        this.el.addEventListener('shown.bs.modal', function()
                        {
                            if (qrcode)
                            {
                                that.el.querySelector('.modal-body').innerHTML = '<img src="' + qrcode + '" />';
                            }

                        }, false);
                    },
                    events: {
                        "click .btn-danger": "clearQRCode",
                    },

                    clearQRCode() {
                        var callback = this.model.get("callback");
                        var token = this.model.get("token");
                        if (callback && token) callback(token);
                    },
                    startSession() {
                        this.el.querySelector('.modal-status').innerHTML = "Please follow the instructions in your IRMA app";
                    },
                    endSession() {
                       this.modal.hide();
                    }
                });

                _converse.api.listen.on('connected', function()
                {
                    console.debug('webmeet connected');
                    openFastPath();
                });

                _converse.api.listen.on('chatRoomOpened', function (view)
                {
                    console.debug("chatRoomOpened", _converse.nickname, view.model.get("nick"), _converse.chatboxviews.model.models.length);
                    document.getElementById("chatloader").style.visibility = "hidden";
                });

                _converse.api.listen.on('chatBoxInitialized', function (view)
                {
                    console.debug("chatBoxInitialized", _converse.nickname, view.model.get("nick"), _converse.chatboxviews.model.models.length);
                    document.getElementById("chatloader").style.visibility = "hidden";
                });

                _converse.api.listen.on('chatBoxClosed', function (view)
                {
                    console.debug("chatBoxClosed", _converse.nickname, view.model.get("nick"), _converse.chatboxviews.model.models.length);

                    if (_converse.chatboxviews.model.models.length == 0)
                    {
                        chatButton.style.visibility = "";
                    }
                });

                _converse.api.listen.on('renderToolbar', function(view)
                {
                    console.debug('ingite - renderToolbar', view.model);

                    if (view.model.get("type") == "chatbox")
                    {
                        view.showHelpMessages(welcome);
                    }
                    else

                    if (view.model.get("type") == "chatroom")
                    {
                        var id = view.model.get("box_id");
                        var jid = view.model.get("jid");

                        var scrolldown = addToolbarItem(view, id, "ignite-scrolldown-" + id, '<a class="fa fa-angle-double-down" title="Scroll to the bottom"></a>');

                        scrolldown.addEventListener('click', function(evt)
                        {
                            evt.stopPropagation();
                            view.viewUnreadMessages()

                        }, false);

                        var screencast = addToolbarItem(view, id, "ignite-screencast-" + id, '<a class="fa fa-desktop" title="ScreenCast. Click to here to start and click here again to stop"></a>');

                        screencast.addEventListener('click', function(evt)
                        {
                            evt.stopPropagation();
                            toggleScreenCast(view);

                        }, false);

                        setTimeout(function()
                        {
                            if (view.model.get("type") == "chatroom")
                            {
                                setNick(view.model.get("nick"));
                            }
                        }, 60000)
                    }
                });

                console.log("webmeet plugin is ready");
            },

            overrides: {
                MessageView: {

                    renderChatMessage: async function renderChatMessage()
                    {
                        if (this.model.vcard)
                        {
                            var nick = this.model.getDisplayName();

                            if (nick && _converse.DEFAULT_IMAGE == this.model.vcard.attributes.image)
                            {
                                var dataUri = createAvatar(nick);
                                var avatar = dataUri.split(";base64,");

                                this.model.vcard.attributes.image = avatar[1];
                                this.model.vcard.attributes.image_type = "image/png";
                            }
                        }

                        await this.__super__.renderChatMessage.apply(this, arguments);
                    }
                }
            }
        });
    }


    function setupAudioConf()
    {
        converse.plugins.add("audioconf", {
            dependencies: [],

            initialize: function () {
                _converse = this._converse;

                _converse.api.settings.update({
                    visible_toolbar_buttons: {call: true},
                });

                window.click2Dial = {
                    custom_button_color: "orange",
                    custom_frame_color: "black",
                    dial_pad: "true",
                    did: "3001",
                    display_button: "false",
                    div_css_class_name: "btn-style-round-a",
                    draggable: "true",
                    incompatible_browser_configuration: "hide_widget",
                    placement: "bottom-right",
                    rating: "false",
                    ringback: "true",
                    server_url: hosted + "/widget",
                    show_branding: "false",
                    show_frame: "true",
                    text: "Ask",
                    use_default_button_css: "true",
                    protocol: "sip",    // 'sip' or 'xmpp'
                    sip: {domain: domain, server: "wss://" + server + "/sip/proxy?url=ws://" + domain + ":5066", register: false, caller_uri: "sip:1002@" + domain, authorization_user: "1002", password: "1234"},
                    xmpp: {domain: "meet.jit.si", server: "https://meet.jit.si/http-bind"}
                }

                const head  = document.getElementsByTagName('head')[0];
                const script  = document.createElement('script');
                script.src = click2Dial.server_url + '/scripts/click2dial.js';
                script.async = false;
                head.appendChild(script);

                console.log("audioconf plugin is ready");
            },

            overrides: {
                ChatBoxView: {

                    toggleCall: function toggleCall(ev) {
                        ev.stopPropagation();
                        var room = converse.env.Strophe.getNodeFromJid(this.model.attributes.jid).toLowerCase();
                        console.debug("toggleCall", room);

                        if (!voxbone.WebRTC.rtcSession.isEnded || voxbone.WebRTC.rtcSession.isEnded())
                        {
                            infoVoxbone.did = "audioconf_" + room;
                            click2Dial.makeCall(true);

                            this.showHelpMessages(["Calling " + infoVoxbone.did]);
                        }
                        else {
                            this.showHelpMessages(["Active call in progress. Clear call and try again"]);
                        }
                    }
                }
            }
        });
    }

    function createAvatar (nickname, width, height, font)
    {
        nickname = nickname.toLowerCase();

        if (avatars[nickname])
        {
            return avatars[nickname];
        }

        if (!width) width = 32;
        if (!height) height = 32;
        if (!font) font = "16px Arial";

        var canvas = document.createElement('canvas');
        canvas.style.display = 'none';
        canvas.width = width;
        canvas.height = height;
        document.body.appendChild(canvas);
        var context = canvas.getContext('2d');
        context.fillStyle = getRandomColor(nickname);
        context.fillRect(0, 0, canvas.width, canvas.height);
        context.font = font;
        context.fillStyle = "#fff";

        var first, last, pos = nickname.indexOf("@");
        if (pos > 0) nickname = nickname.substring(0, pos);

        var name = nickname.split(" ");
        if (name.length == 1) name = nickname.split(".");
        if (name.length == 1) name = nickname.split("-");
        var l = name.length - 1;

        if (name && name[0] && name.first != '')
        {
            first = name[0][0];
            last = name[l] && name[l] != '' && l > 0 ? name[l][0] : null;

            if (last) {
                var initials = first + last;
                context.fillText(initials.toUpperCase(), 3, 23);
            } else {
                var initials = first;
                context.fillText(initials.toUpperCase(), 10, 23);
            }
            var data = canvas.toDataURL();
            document.body.removeChild(canvas);
        }

        var dataUrl = canvas.toDataURL();
        avatars[nickname] = dataUrl;
        return dataUrl;
    }

    function getRandomColor (nickname)
    {
        if (nickColors[nickname])
        {
            return nickColors[nickname];
        }
        else {
            var letters = '0123456789ABCDEF';
            var color = '#';

            for (var i = 0; i < 6; i++) {
                color += letters[Math.floor(Math.random() * 16)];
            }
            nickColors[nickname] = color;
            return color;
        }
    }

    function __newElement (el, id, html, className)
    {
        var ele = document.createElement(el);
        if (id) ele.id = id;
        if (html) ele.innerHTML = html;
        if (className) ele.classList.add(className);
        document.body.appendChild(ele);
        return ele;
    }

    function addToolbarItem (view, id, label, html)
    {
        var placeHolder = view.el.querySelector('#place-holder');

        if (!placeHolder)
        {
            var smiley = view.el.querySelector('.toggle-smiley.dropup');
            smiley.insertAdjacentElement('afterEnd', __newElement('li', 'place-holder'));
            placeHolder = view.el.querySelector('#place-holder');
        }
        var newEle = __newElement('li', label, html);
        placeHolder.insertAdjacentElement('afterEnd', newEle);
        return newEle;
    }


    function toggleScreenCast (view)
    {
        if (videoRecorder == null)
        {
            getDisplayMedia().then(stream =>
            {
                handleStream(stream, view);

            }, error => {
                handleError(error)
            });

        } else {
            videoRecorder.stop();
        }

        return true;
    }

    function getDisplayMedia ()
    {
        if (navigator.getDisplayMedia) {
          return navigator.getDisplayMedia({video: true});
        } else if (navigator.mediaDevices.getDisplayMedia) {
          return navigator.mediaDevices.getDisplayMedia({video: true});
        } else {
          return navigator.mediaDevices.getUserMedia({video: {mediaSource: 'screen'}});
        }
    }

    function handleStream (stream, view)
    {
        navigator.mediaDevices.getUserMedia({audio: true, video: false}).then((audioStream) => handleAudioStream(stream, audioStream, view)).catch((e) => handleError(e))
    }

    function handleAudioStream (stream, audioStream, view)
    {
        console.debug("handleAudioStream - seperate", stream, audioStream);

        stream.addTrack(audioStream.getAudioTracks()[0]);
        audioStream.removeTrack(audioStream.getAudioTracks()[0]);

        console.debug("handleAudioStream - merged", stream);

        var video = document.createElement('video');
        video.playsinline = true;
        video.autoplay = true;
        video.muted = true;
        video.srcObject = stream;
        video.style.display = "none";

        setTimeout(function()
        {
            videoRecorder = new MediaRecorder(stream);
            videoChunks = [];

            videoRecorder.ondataavailable = function(e)
            {
                console.debug("handleStream - start", e);

                if (e.data.size > 0)
                {
                    console.debug("startRecorder push video ", e.data);
                    videoChunks.push(e.data);
                }
            }

            videoRecorder.onstop = function(e)
            {
                console.debug("handleStream - stop", e);

                stream.getTracks().forEach(track => track.stop());

                var blob = new Blob(videoChunks, {type: 'video/webm;codecs=h264'});
                var file = new File([blob], "screencast-" + Math.random().toString(36).substr(2,9) + ".webm", {type: 'video/webm;codecs=h264'});
                view.model.sendFiles([file]);
                videoRecorder = null;
            }

            videoRecorder.start();
            console.debug("handleStream", video, videoRecorder);

        }, 1000);
    }

    function handleError (e)
    {
        console.error("ScreenCast", e)
    }

    function loadJS(name)
    {
        var s1 = document.createElement('script');
        s1.src = hosted + "/" + name;
        s1.async = false;
        document.body.appendChild(s1);
    }

    function loadCSS(name)
    {
        var head  = document.getElementsByTagName('head')[0];
        var link  = document.createElement('link');
        link.rel  = 'stylesheet';
        link.type = 'text/css';
        link.href = hosted + "/" + name;
        head.appendChild(link);
    }

    //-------------------------------------------------------
    //
    //  Exports
    //
    //-------------------------------------------------------

    of.doBadge = function doBadge(count)
    {
        var unreadMessageHeading = document.getElementById("unreadMessageHeading");
        var unreadMessageIndicator = document.getElementById("unreadMessageIndicator");

        if (count == 0)
        {
            unreadMessageIndicator.style.visibility = "hidden";

        } else {
            unreadMessageIndicator.style.visibility = "visible";
            unreadMessageHeading.innerText = count;
        }
    }

    of.doExit = function doExit()
    {
        document.getElementById("chatbutton").style.visibility = "visible";
        of.doBadge(0);
    }

    of.joinWorkgroupQueue = function joinWorkgroupQueue(form)
    {
        joinWorkgroup(form);
    }

    of.loaded = false;

    //-------------------------------------------------------
    //
    //  Startup
    //
    //-------------------------------------------------------

    var div = document.createElement('div');
    div.innerHTML = '<div id="conversejs" class="theme-concord"></div>';
    document.body.appendChild(div);

    var root = document.createElement("div");
    root.innerHTML = '<div class="ofmeet-button bubble"><img id="chatloader" class="lwc-chat-button" style="visibility:hidden" src="' + hosted + '/widget/ajax-loader.gif" /> <a id="chatbutton" class="lwc-chat-button"> <span id="unreadMessageIndicator" class="unreadMessageIndicator"><h3 id="unreadMessageHeading" class="heading">5</h3></span> <span class="lwc-button-icon"> <svg viewBox="0 0 38 35" style="width: inherit"> <path fill="#FFF" fill-rule="evenodd" d="M36.9 10.05c-1-4.27-4.45-7.6-8.8-8.4-2.95-.5-6-.78-9.1-.78-3.1 0-6.15.27-9.1.8-4.35.8-7.8 4.1-8.8 8.38-.4 1.5-.6 3.07-.6 4.7 0 1.62.2 3.2.6 4.7 1 4.26 4.45 7.58 8.8 8.37 2.95.53 6 .45 9.1.45v5.2c0 .77.62 1.4 1.4 1.4.3 0 .6-.12.82-.3l11.06-8.46c2.3-1.53 3.97-3.9 4.62-6.66.4-1.5.6-3.07.6-4.7 0-1.62-.2-3.2-.6-4.7zm-14.2 9.1H10.68c-.77 0-1.4-.63-1.4-1.4 0-.77.63-1.4 1.4-1.4H22.7c.76 0 1.4.63 1.4 1.4 0 .77-.63 1.4-1.4 1.4zm4.62-6.03H10.68c-.77 0-1.4-.62-1.4-1.38 0-.77.63-1.4 1.4-1.4h16.64c.77 0 1.4.63 1.4 1.4 0 .76-.63 1.38-1.4 1.38z"></path></svg> </span> <span id="chatIconText" class="lwc-button-text">Contact us</span> </a></div> <div class="ofmeet-chat"></div>';
    document.body.appendChild(root);

    loadCSS('ofmeet.css');
    loadCSS('widget/converse.css');
    loadCSS('widget/stylesheets/concord.css');
    loadJS('widget/converse.js');


    return of;

}(ofmeet || {}));

