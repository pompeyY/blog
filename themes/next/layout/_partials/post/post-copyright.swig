{%- set ccIcon = '<i class="fab fa-fw fa-creative-commons"></i>' %}
{%- set ccText = theme.creative_commons.license | upper %}


<div>
<ul class="post-copyright">
  <li class="post-copyright-author">
    <strong>{{ __('post.copyright.author') + __('symbol.colon') }} </strong>
    {{- page.author or author }}
  </li>
  <li class="post-copyright-link">
    <strong>{{ __('post.copyright.link') + __('symbol.colon') }}</strong>
    {#{ next_url(page.permalink, page.permalink, {title: page.title}) }#}
    {{ next_url('https://pompeyy.github.io'+ url_for(page.path), 'https://pompeyy.github.io'+ url_for(page.path), {title: page.title}) }}
    
  </li>
  <li class="post-copyright-license">
    <strong>{{ __('post.copyright.license_title') + __('symbol.colon') }} </strong>
    {{- __('post.copyright.license_content', next_url(ccURL, ccIcon + ccText)) }}
  </li>
</ul>
</div>

{#<div class="post-copyright">
  <script src="//cdn.bootcss.com/clipboard.js/1.5.10/clipboard.min.js"></script>
  
  <!-- JS库 sweetalert 可修改路径 -->
  <script type="text/javascript" src="http://jslibs.wuxubj.cn/sweetalert_mini/jquery-1.7.1.min.js"></script>
  <script src="http://jslibs.wuxubj.cn/sweetalert_mini/sweetalert.min.js"></script>
  <link rel="stylesheet" type="text/css" href="http://jslibs.wuxubj.cn/sweetalert_mini/sweetalert.mini.css">

  <p><span>本文标题: </span>{{ page.title }}</a></p>
  <p><span>文章作者: </span>{{ page.author or author }}</a></p>
  <p><span>发布时间: </span>{{ page.date.format("YYYY年MM月DD日 HH:mm:ss") }}</p>
  <p><span>最后更新: </span>{{ page.updated.format("YYYY年MM月DD日 HH:mm:ss") }}</p>
  <p><span>原始链接: </span><a href="{{ url_for(page.path) }}" title="{{ page.title }}">{{ page.permalink }}</a>
    <span class="copy-path"  title="点击复制文章链接"> <i class="fa fa-clipboard" data-clipboard-text="{{ page.permalink }}"  aria-label="复制成功！"></i></span>
  </p>
  <p><span>许可协议: </span><i class="fa fa-creative-commons"></i><a rel="license" href="https://creativecommons.org/licenses/by-nc-nd/4.0/" target="_blank" title="Attribution-NonCommercial-NoDerivatives 4.0 International (CC BY-NC-ND 4.0)">Pompeyy-非商业性使用-禁止演绎 4.0 国际</a> 转载请保留原文链接及作者。</p>  
</div>
<script> 
    var clipboard = new Clipboard('.fa-clipboard');
    clipboard.on('success', $(function(){
      $(".fa-clipboard").click(function(){
        swal({   
          title: "",   
          text: '复制成功',   
          html: false,
          timer: 500,   
          showConfirmButton: false
        });
      });
    }));  
</script>
#}
