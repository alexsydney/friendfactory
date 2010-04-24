jQuery(document).ready(function($) {
	$(document).bind('connect', function(ev, data){
		var conn = new Strophe.Connection("http://bosh.metajack.im:5280/xmpp-httpbind");
		// var conn = new Strophe.Connection("http://friskyhands.com:5280/http-bind");
		conn.connect(data.jid, data.password, function(status) {
			if (status === Strophe.Status.CONNECTED) {
				$(document).trigger('connected');	
			} else if (status === Strophe.Status.DISCONNECTED) {
				$(document).trigger('disconnected')
			}
		});		
		Chat.connection = conn;
	});
	
	$(document).bind('connected', function(){
		FF.log('Connected!');
		Chat.connection.addHandler(Chat.handlePong, null, "iq", null, "ping1");
		var domain = Strophe.getDomainFromJid(Chat.connection.jid);
		Chat.ping(domain);
	});

	$(document).bind('disconnected', function(){
		$('#log').append('Disconnected!');
		Chat.connection = null;
	});	
});

jQuery(document).ready(function($){
	$(document).trigger('connect', {
		// jid: 'mjbamford@jabber.rootbash.com',
		// password: 'lee201'
		// jid: 'mjbamford@jabber.co.nz',
		// password: 'lee201'
		jid: 'mjbamford@friskyhands.com',
		password: 'lee201AA'
	});
});
