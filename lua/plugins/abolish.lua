return {
  "tpope/vim-abolish",
  -- enabled = false,
  lazy = false,
  config = function()
    vim.cmd([[
      " Health Economics Terms (previous terms remain the same)
      Abolish {,n}hs{,s} NHS
      Abolish {q,w,Q}{a,u}ly QALY
      Abolish {q,w,Q}{a,u}lys QALYs
      Abolish {daly,daley}{,s} DALY{,s}
      "Abolish icer ICER
      "Abolish icers ICERs
      iabbrev icer ICER
      iabbrev icers ICERs
      iabbrev Icer ICER
      iabbrev Icers ICERs
      iabbrev ICER ICER
      iabbrev ICERS ICERs
      Abolish {h,}ta HTA
      Abolish {n,N}ice NICE
      Abolish {rct,rect} RCT
      Abolish {rcts,rects} RCTs
      Abolish {hrqol,hrql,hrquol} HRQoL
      Abolish {qol,quol} QoL

      " Contractions - Complete List
      Abolish wont won't
      Abolish cant can't
      Abolish isnt isn't
      Abolish dont don't
      Abolish doesnt doesn't
      Abolish wasnt wasn't
      Abolish werent weren't
      Abolish didnt didn't
      Abolish ive I've
      Abolish theyre they're
      Abolish youre you're
      Abolish thats that's
      Abolish theres there's
      Abolish whos who's
      Abolish whats what's
      Abolish wheres where's
      Abolish hows how's
      Abolish itll it'll
      Abolish shouldnt shouldn't
      Abolish couldnt couldn't
      Abolish wouldnt wouldn't
      Abolish arent aren't
      Abolish its it's
      Abolish weve we've
      Abolish youd you'd
      Abolish shed she'd
      Abolish hed he'd
      Abolish theyd they'd
      Abolish wed we'd
      Abolish youve you've
      Abolish hes he's
      Abolish shes she's
      Abolish Ill I'll
      Abolish youll you'll
      Abolish hell he'll
      Abolish shell she'll
      Abolish theyll they'll
      Abolish hasnt hasn't
      Abolish havent haven't
      Abolish shouldve should've
      Abolish couldve could've
      Abolish wouldve would've
      Abolish mightve might've
      Abolish mustve must've
      Abolish id I'd
      Abolish itd it'd
      Abolish thereve there've
      Abolish wholl who'll
      Abolish theyve they've
      Abolish hadnt hadn't
      Abolish aint ain't
    ]])
  end,
}
