xml = require './src/xml'

console.log xml.prettify {
  tag: 'html'
  attrs: {
    test: 1
    class: 'test me out'
  }
  children: [
    {
      tag: 'body'
      attrs: {
        test: 1
        class: 'test me out'
        test2: 1
        class2: 'test me out'
        test3: 1
        class3: 'test me out'
        test4: 1
        class4: 'test me out'
        test5: 1
        class5: 'test me out'
        test6: 1
        class6: 'test me out'
      }
      children: [
        {
          tag: 'p'
          attrs: {}
          children: [
            'This is a test line'
          ]
        }
        {
          tag: 'p'
          attrs: {
            class: 'foo bar'
            align: 'center'
          }
          children: [
            'This is a test line'
          ]
        }
        {
          tag: 'p'
          attrs: {}
          children: [
            'This is a test line'
          ]
        }
        {
          tag: 'br'
        }
        {
          tag: 'p'
          attrs: {}
          children: [
            'This is a test line'
          ]
        }
        {
          tag: 'p'
          attrs: {}
          children: [
            'This is a test line'
            { tag: 'br' }
          ]
        }
        {
          tag: 'p'
          attrs: {}
          children: [
            'This is a test line'
          ]
        }
        {
          tag: 'p'
          attrs: {}
          children: [
            'This is a test line'
          ]
        }
      ]
    }
  ]
}

