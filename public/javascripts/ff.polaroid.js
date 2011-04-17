(function($) {
	
	$.fn.chat = function() {

		var $this = $(this), // wave_conversation	
			pusher = new Pusher('064cfff6a7f7e44b07ae'),
			channelId = $this.attr('id'),
			channel = pusher.subscribe(channelId);

		channel.bind('message', function(data) {
			$.get(data['url'], function(partial) {
				var $threadDiv = $('.thread', data['dom_id']).append(partial);
				// $threadDiv[0].scrollTop = $threadDiv[0].scrollHeight;
				$threadDiv.scrollTo('max', 200);
			});
		});

		$this
			.find('form')
				.find('button[type="submit"]')
					.hide()
				.end()
				
				.find('textarea')
					.bind('keydown', function(event) {
						if (event.keyCode == '13') {
							event.preventDefault();
							$(this).closest('form').submit();
						} else if (event.keyCode == '27') {
							$(event.target).closest('.postcard')
								.fadeOut(function() {
									$(this).closest('.floating').andSelf().remove();
								});
						}
					})
				.end()

				.bind('submit', function() {
					var msg = $(this).find('textarea').val();
					if (msg.length == 0) { return false; }			
				})
				
				.bind('ajax:loading', function() {
					var $this = $(this),
						$textarea = $this.find('textarea#posting_message_body'),
						$thread = $this.closest('.wave_conversation').find('.thread');

					$thread.append($("<li><div class='posting posting_message sent'>" + $textarea.val() + "</div></li>"));
					// $thread[0].scrollTop = $thread[0].scrollHeight;
					$thread.scrollTo('max', 200);
					$textarea.val('');
				})
			.end()

			.find('.thread')
				.each(function(idx, thread) {
					thread.scrollTop = thread.scrollHeight;
				});
	}

	
	$.fn.polaroid = function(options) {

		var settings = {
				'close-button' : false			
			},
			
			panes = {
				init: function(scrollable, idx) {
					var panes = this,
						$pane = $(scrollable.getRoot()).find('.pane:eq(' + idx + ')'),
						paneName = $pane.data('pane'),
						profileId = $pane.closest('.polaroid').attr('data-profile_id');						
					
					$pane.load('/wave/profiles/' + profileId + '/' + paneName, function(event) {
						if (panes[paneName] !== undefined) {
							panes[paneName]($pane);
						}						
					});					
				},
				
				conversation: function($pane) {
					$pane.find('.wave_conversation').chat();
				}
			}
		
		$.extend(settings, options);		
		
		if (Modernizr.csstransforms3d) {
			
			return this.each(function() {
				var $this = $(this), // a polaroid
					$backFace = $this.find('.back.face'),
					transitionDuration = $this.css('-webkit-transition-duration');
									
				console.log(transitionDuration);
				
				$this.css({ '-webkit-transition-duration': '0s' })
					.addClass('flipped');
					
				$backFace.find('.content').css({ opacity: 0.0 });

				if (settings['close-button'] === true) {
					$('a.close', $this).click(function(event) {
						$(event.target).closest('.floating')
							.fadeOut(function() {
								$(this).remove();
							});
						return false;
					});
				}
				
				$backFace
					// .css('-webkit-transform', 'rotateY(180deg)')
					.find('.scrollable')
						.scrollable({
							items: 'items',
							keyboard: false,
							next: '',
							prev: '',
							onSeek: function(event, idx) {
								panes.init(this, idx);
							}
						}).navigator()						
					.end()
					
					.find('.buddy-bar a.flip')
						.click(function(event) {
							event.preventDefault();							
							$backFace.find('.content').fadeTo('fast', 0.0);
							$this.css({ '-webkit-transition-duration': transitionDuration }).toggleClass('flipped');
						})
					.end()										
				.end()
				
				.find('.front.face .buddy-bar a.flip')
					.click(function(event) {			
						var idx = $(this).closest('li').index();

						event.preventDefault();	
						
						// Undo the rotate and manually scroll to correct pane.
						$backFace.css('-webkit-transform', 'rotateY(180deg)')
							.find('.scrollable').scrollable().seekTo(idx, 0);							
						$backFace.css('-webkit-transform', 'none')
							.find('.content').delay(1000).fadeTo('fast', 1.0);													

						$this.css({ '-webkit-transition-duration': transitionDuration }).toggleClass('flipped');
					})
				.end();
						
			}); // each
			
		} else {
						
			return this.each(function() {				
				var $this = $(this); // a polaroid
				
				$this.find('.face-container:eq(1)').hide();
				
				if (settings['close-button'] === true) {
					$('a.close', $this).live('click', function(event) {
						$this.fadeOut();
						$(event.target).closest('.floating').remove();
						return false;
					});
				}				

				$this.find('.front .buddy-bar a.flip').live('click', function(event) {
		    		event.preventDefault();
					
					var $polaroid = $(this).closest('.polaroid');
					$polaroid.data('scrollable-index', $(this).closest('li').index());
					
		    		$polaroid.flip({
						speed: 300,
		      			direction: 'lr',
		      			color: '#FFF',
		      			content: $polaroid.find('.face-container:hidden'),
				
		      			onEnd: function() {
					  		$polaroid.find('.buddy-bar a.flip').click(function(event) {
								event.preventDefault();
								$polaroid.revertFlip();								
							});

							// Make links work on backside
							$polaroid.find('.scrollable').scrollable({
								items: 'items',
								keyboard: false,
								next: '',
								prev: '',							
	      	    				onSeek: function(event, idx) {
									panes.init(this, idx);
	      	    				}
							}).navigator();

							var idx = $polaroid.data('scrollable-index');
							$polaroid.find('.scrollable').scrollable().seekTo(idx ,0);
		      			} // onEnd		
		    		}); // flip
		
		  		}); // live
		
			}); // each
			
		} // if
		
	}; // fn.polaroid
	
})(jQuery);
