(function($) {

	$.fn.closeHeadshot = function() {
		return this.click(function(event) {
			$(event.target).closest('.wave_profile')
				.fadeOut(function() {
					var $this = $(this),
						$floating = $this.closest('.floating'),
						$backFace = $this.find('.back.face'),
						scrollable = $backFace.find('.scrollable').scrollable(),
						conversationId = $backFace.find('.wave_conversation').data('id');

					$this.remove();

					if ($floating.length > 0) {
						$floating.remove();
					} else {
						if ((scrollable.getIndex !== undefined) && (scrollable.getIndex() === 3)) {
							$.ajax({
								url: '/wave/conversations/' + conversationId + '/close',
								data: [],
								dataType: 'json',
								type: 'PUT'
							});
						}
					}
				});
			return false;
		});
	}

	$.fn.polaroid = function(options) {
		var settings = {
				'close-button' : false,
				'set-focus' : true
			},

			panes = {
				init: function(scrollable, idx, setFocus) {
					var $pane = $(scrollable.getRoot()).find('.pane:eq(' + idx + ')');
					loadPane($pane, setFocus);
				},

				tearDown: function(scrollable, idx) {
					var $pane = $(scrollable.getRoot()).find('.pane.conversation');
					$pane.find('.message-input').hide();
				},

				conversation: function($pane, setFocus) {
					$pane.find('.wave_conversation').chat();
					if (setFocus === true) {
						$pane.find('textarea').focus();
					}
				},
				
				pokes: function($pane) {
					$pane.find('a.profile').bind('click', function(event) {
						event.preventDefault();
						$('<div class="floating"></div>')
							.appendTo('.floating-container')
							.load($(this).attr('href'), function() {	 			
								$(this).position({
									my: 'left center',
									of: event,
									offset: '30 0',
									collision: 'fit'
								})	
							.draggable()
							.find('div.polaroid')
								.polaroid({ 'close-button' : true });
						});
					});
				}
			},

			loadPane = function(pane, setFocus) {
				var $pane = $(pane),
					paneName = $pane.data('pane'),
					profileId = $pane.closest('.polaroid').attr('data-profile_id');

				$pane.load('/wave/profiles/' + profileId + '/' + paneName + '?legacy=true', function(event) {
					if (panes[paneName] !== undefined) {
						panes[paneName]($pane, setFocus || false);
					}
				});
			};

		$.extend(settings, options);

		if (Modernizr.csstransforms3d) {
			return this.each(function() {
				var $this = $(this), // a polaroid
					$backFace = $this.find('.back.face'),
					$frontFace = $this.find('.front.face'),
					transitionDuration = $this.css('-webkit-transition-duration'),
					setFocus = settings['set-focus'];

				if (settings['pane'] === undefined) {
					$this.css({ '-webkit-transition-duration': '0s' }).addClass('flipped');
					$backFace.find('.content').css({ opacity: 0.0 });
				}

				if (settings['close-button'] === true) {
					$('a.close', $this).closeHeadshot();
				}

				$backFace
					// .css('-webkit-transform', 'rotateY(180deg)')
					.find('.scrollable')
						.scrollable({
							items: 'items',
							keyboard: false,
							next: '',
							prev: '',
							onBeforeSeek: function(event, idx) {
								panes.tearDown(this, idx);
							},
							onSeek: function(event, idx) {
								panes.init(this, idx, setFocus);
							}
						}).navigator()
					.end()

					.find('.buddy-bar a.flip')
						.click(function(event) {
							event.preventDefault();
							$backFace.find('.content').fadeTo('fast', 0.0, function() {
								$this.css({ '-webkit-transition-duration': transitionDuration }).toggleClass('flipped');
							});
						})
					.end()

					.find('.pane.pokes a.poke')
						.live('ajax:complete', function() {
							$(this).hide();
						})
						.live('ajax:success', function(data, status, xhr) {
							var $pane = $(this).closest('.pane');
							loadPane($pane);
							$(this).closest('.polaroid').find('a.pokes')
								.toggleClass('poked', status['poked']);
						});

				$frontFace
					.find('.buddy-bar a.flip')
						.click(function(event) {
							var idx = $(this).closest('li').index();
							event.preventDefault();

							// Undo the rotate and manually scroll to correct pane.
							$backFace.css('-webkit-transform', 'rotateY(180deg)')
								.find('.scrollable').scrollable().seekTo(idx, 0);
							$backFace.css('-webkit-transform', 'none')
								.find('.content').delay(900).fadeTo('fast', 1.0);

							$this.css({ '-webkit-transition-duration': transitionDuration }).toggleClass('flipped');
						});

				if (settings['pane'] !== undefined) {
					$backFace.find('.scrollable').scrollable().seekTo(settings['pane'], 0);
					setFocus = true;
				}
			}); // each

		} else {
			// no-csstransforms3d
			return this.each(function() {
				var $this = $(this), // a polaroid
					$frontFace = $this.find('.front.face'),
					$backFace = $this.find('.back.face'),
					setFocus = settings['set-focus'],
					scrollableSettings = {
						items: 'items',
						keyboard: false,
						next: '',
						prev: '',
						onBeforeSeek: function(event, idx) {
							panes.tearDown(this, idx);
						},									
	   	    			onSeek: function(event, idx) {
							panes.init(this, idx, setFocus);
	   	    			}						
					};	

				if (settings['close-button'] === true) {
					$('a.close', $this).closeHeadshot();
				}

				$backFace
					.find('.pane.pokes a.poke')
						.live('ajax:complete', function() {
							$(this).hide();
						})
						.live('ajax:success', function(data, status, xhr) {
							var $pane = $(this).closest('.pane');
							loadPane($pane);
							$(this).closest('.polaroid').find('a.pokes')
								.toggleClass('poked', status['poked']);
						});

				if (settings['pane'] === undefined) {
					$this
						.find('.face-container:eq(1)')
							.hide()
						.end()
						.find('.face-container:eq(0) .buddy-bar a.flip')
							.live('click', function(event) {
								var $polaroid = $(this).closest('.polaroid');
					    		event.preventDefault();
								$polaroid
									.data('scrollable-index', $(this).closest('li').index())
									.flip({
										speed: 300,
						      			direction: 'lr',
						      			color: '#FFF',
						      			content: $polaroid.find('.face-container:hidden'),				
						      			onEnd: function() {
									  		$polaroid
												.find('.buddy-bar a.flip')
													.click(function(event) {
														event.preventDefault();
														$polaroid.revertFlip();								
													});

											// Make links work on backside												
											$polaroid.find('.scrollable')
												.scrollable(scrollableSettings)
												.navigator();

											if (settings['close-button'] === true) {
												$('a.close', $polaroid).closeHeadshot();
											}

											var idx = $polaroid.data('scrollable-index') || 0; 
											$polaroid.find('.scrollable').scrollable().seekTo(idx, 0);
						      			} // onEnd		
						    		}); // flip		
					  		}); // live

				} else {
					var flippery = function(event) {
							var $polaroid = $(event.target).closest('.polaroid');	
							event.preventDefault();
							$polaroid
								.flip({
									speed: 300,
					      			direction: 'lr',
					      			color: '#FFF',
					      			content: $polaroid.find('.face-container:hidden'),
									onEnd: function() {
										if (settings['close-button'] === true) {
											$('a.close', $polaroid).closeHeadshot();
										}

										$polaroid
											.find('.front.face:not(:hidden) .buddy-bar a.flip')
												.bind('click', function(event) {
													event.preventDefault();
													$polaroid
														.data('scrollable-index', $(event.target).closest('li').index())																										
														.revertFlip();
												})
											.end()
								
											.find('.back.face:not(:hidden)')
											 	.find('.buddy-bar a.flip')
													.bind('click', flippery)
												.end()
												.find('.scrollable')
													.scrollable(scrollableSettings)
													.navigator();
										
										if ($polaroid.find('.back.face').length == 1) {
											var idx = $polaroid.data('scrollable-index');
											$polaroid.find('.scrollable').scrollable().seekTo(idx ,0);											
										}
									} // onEnd
								});
						};
					
					$this
						.find('.face-container:eq(0)')
							.hide()
						.end()						
						.find('.face-container:eq(1)')
							.find('.buddy-bar a.flip')
								.click(flippery)
							.end()						
							.find('.scrollable')
								.scrollable(scrollableSettings)
								.navigator();
						
					$this.find('.scrollable').scrollable().seekTo(settings['pane'], 0);
					setFocus = true;					
				} // if
			}); // each						
		} // if		
	}; // fn.polaroid
	
})(jQuery);
