jQuery(function($){
  $('.polaroid').draggable({ handle: '.gripper' })
	if ($.browser.safari){
		$('.polaroid .back').css('-webkit-transform', 'rotateY(180deg)');
	  $('.polaroid .back .scrollable').scrollable({
	    items: 'items',
	    keyboard: false,
	    next: '',
	    prev: ''
	  }).navigator();
          
	  $('.polaroid .front .buddy-bar a.flip').click(function(event){
	    event.preventDefault();	
	    $(this).addClass('current').closest('.polaroid').toggleClass('flipped').find('.gripper').hide();
	  });

	  $('.polaroid .back .buddy-bar a.flip').click(function(event){
	    event.preventDefault();	
	    $(this).closest('.polaroid').toggleClass('flipped').find('.gripper').hide();
	  });
    
	  $('.polaroid').each(function(idx, polaroid){
	    polaroid.addEventListener('webkitTransitionEnd', function(event){
				var $polaroid = $(event.target);
	      var $current = $polaroid.find('.front.face .buddy-bar .current')
	      $polaroid.find('.back .buddy-bar .' + $current.attr('href')).click();
				$polaroid.find('.back .gripper').show();				
				if (!$polaroid.hasClass('flipped')) {
					$polaroid.find('.front .gripper').show();
				}
	      $current.removeClass('current');
	    });
	  });
	
	} else {
		$('.polaroid').find('.face-container:eq(1)').hide();
	  $('.polaroid .front .buddy-bar a.flip').live('click', function(event){
	    event.preventDefault();
			var $polaroid = $(this).closest('.polaroid');			
			$polaroid.data('current', $(this).attr('href'));
			
	    $polaroid.flip({
				speed: 280,
	      direction: 'lr',
	      color: '#FFF',
	      content: $polaroid.find('.face-container:hidden'),
	      onEnd: function(){
					$polaroid.draggable().find('.buddy-bar a.flip').click(function(event){
						event.preventDefault();
						$polaroid.revertFlip();
					});

					$polaroid.find('.scrollable').scrollable({
						items: 'items',
						keyboard: false,
						next: '',
						prev: ''
					}).navigator();
				
	       	$polaroid.find('.navi .' + $polaroid.data('current')).click();
	      }
	    });
	  });
	}
});