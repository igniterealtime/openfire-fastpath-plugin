<%@ page import="org.jivesoftware.util.*, org.jivesoftware.openfire.*, java.util.*, java.net.URLEncoder"  %>
<%
    String hostname = XMPPServer.getInstance().getServerInfo().getHostname();
    String domain = XMPPServer.getInstance().getServerInfo().getXMPPDomain();    
    String port = JiveGlobals.getProperty("httpbind.port.secure", "7443");
    String host = hostname + ":" + port;
    String url = "https://" + host;
%>
<html>
<head>
<link id="favicon" rel="icon" href="favicon.ico">
<title>Website for Demo Workgroup</title>
</head>
<body>
    <h1>Website for Demo Workgroup</h1>
    <p>first line</p>
    <p>
        Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras consequat felis nulla, tincidunt ultricies nisi semper ut. Donec tempor tincidunt orci, sit amet facilisis sapien dapibus ut. Nulla nunc tortor, ultrices quis pellentesque vitae, fermentum vel libero. Nunc sodales nisi a turpis ultricies, vel accumsan lacus aliquam. Proin luctus nunc quis velit sodales, eu sollicitudin nulla facilisis. Praesent tempor nunc vel leo venenatis hendrerit. Donec vestibulum dui non ex blandit dictum. Fusce venenatis fringilla ante in bibendum. Integer euismod dictum dui ac feugiat.

        Ut egestas risus lacus, sit amet ultrices nibh auctor eget. In aliquet porta bibendum. In suscipit aliquet libero, sit amet pretium diam mollis quis. Etiam lacinia facilisis ex eu maximus. In sit amet lorem in mauris rhoncus consequat eget at urna. Nunc id ligula efficitur, volutpat nibh in, venenatis ex. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi quis tristique ipsum. Praesent justo risus, pulvinar nec mauris vel, varius rutrum massa. Donec luctus, sapien eu scelerisque varius, turpis odio viverra ante, et rhoncus massa nisi quis risus. Vestibulum efficitur malesuada nisl, sit amet porttitor ipsum consectetur vel.

        Nulla facilisi. Morbi eu eros tortor. Etiam vitae ex a metus sodales egestas. Integer consequat eros tortor, et molestie eros consequat et. Fusce tellus tellus, varius sit amet purus et, mattis aliquam nulla. Curabitur volutpat sapien vel lorem vestibulum consectetur. Vestibulum volutpat sit amet nunc ac maximus. Etiam rutrum nisi ac orci congue, vitae venenatis est dapibus. Aliquam erat volutpat. Donec dictum commodo dolor at dignissim. Morbi eget lorem sagittis, vestibulum sem ac, tristique massa.

        Nullam ornare neque eget justo dignissim pellentesque. Donec condimentum vitae felis sed dignissim. Nunc ac turpis eget velit congue suscipit eu sed elit. In interdum posuere viverra. Phasellus aliquam urna sollicitudin est sodales condimentum. Mauris sed lacus vitae mi dignissim blandit vulputate sed augue. Phasellus lacinia posuere dui eu mollis. Quisque ornare erat vitae leo malesuada dapibus. Proin interdum fringilla turpis. Ut nulla ligula, vulputate ac aliquet quis, cursus sed nibh.

        In in pulvinar urna, et pellentesque augue. Donec id consequat mauris. Praesent porttitor auctor lacus ut blandit. Nullam porta mauris eget enim ornare, quis semper risus aliquam. Duis sit amet euismod ante, vel laoreet orci. Aliquam blandit orci at dolor pretium ultricies. Vivamus a leo in sapien volutpat volutpat non ut tortor. Sed varius sem elit, a ultrices lorem dapibus sed. Proin non fringilla sapien. Ut et tellus scelerisque, rutrum felis non, tristique eros. Pellentesque nec diam semper, commodo nunc ac, pharetra urna. Sed feugiat quam vel interdum vehicula. Praesent nec iaculis magna.
    </p>
    <p>&nbsp;</p>
    <p>
        Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras consequat felis nulla, tincidunt ultricies nisi semper ut. Donec tempor tincidunt orci, sit amet facilisis sapien dapibus ut. Nulla nunc tortor, ultrices quis pellentesque vitae, fermentum vel libero. Nunc sodales nisi a turpis ultricies, vel accumsan lacus aliquam. Proin luctus nunc quis velit sodales, eu sollicitudin nulla facilisis. Praesent tempor nunc vel leo venenatis hendrerit. Donec vestibulum dui non ex blandit dictum. Fusce venenatis fringilla ante in bibendum. Integer euismod dictum dui ac feugiat.

        Ut egestas risus lacus, sit amet ultrices nibh auctor eget. In aliquet porta bibendum. In suscipit aliquet libero, sit amet pretium diam mollis quis. Etiam lacinia facilisis ex eu maximus. In sit amet lorem in mauris rhoncus consequat eget at urna. Nunc id ligula efficitur, volutpat nibh in, venenatis ex. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi quis tristique ipsum. Praesent justo risus, pulvinar nec mauris vel, varius rutrum massa. Donec luctus, sapien eu scelerisque varius, turpis odio viverra ante, et rhoncus massa nisi quis risus. Vestibulum efficitur malesuada nisl, sit amet porttitor ipsum consectetur vel.

        Nulla facilisi. Morbi eu eros tortor. Etiam vitae ex a metus sodales egestas. Integer consequat eros tortor, et molestie eros consequat et. Fusce tellus tellus, varius sit amet purus et, mattis aliquam nulla. Curabitur volutpat sapien vel lorem vestibulum consectetur. Vestibulum volutpat sit amet nunc ac maximus. Etiam rutrum nisi ac orci congue, vitae venenatis est dapibus. Aliquam erat volutpat. Donec dictum commodo dolor at dignissim. Morbi eget lorem sagittis, vestibulum sem ac, tristique massa.

        Nullam ornare neque eget justo dignissim pellentesque. Donec condimentum vitae felis sed dignissim. Nunc ac turpis eget velit congue suscipit eu sed elit. In interdum posuere viverra. Phasellus aliquam urna sollicitudin est sodales condimentum. Mauris sed lacus vitae mi dignissim blandit vulputate sed augue. Phasellus lacinia posuere dui eu mollis. Quisque ornare erat vitae leo malesuada dapibus. Proin interdum fringilla turpis. Ut nulla ligula, vulputate ac aliquet quis, cursus sed nibh.

        In in pulvinar urna, et pellentesque augue. Donec id consequat mauris. Praesent porttitor auctor lacus ut blandit. Nullam porta mauris eget enim ornare, quis semper risus aliquam. Duis sit amet euismod ante, vel laoreet orci. Aliquam blandit orci at dolor pretium ultricies. Vivamus a leo in sapien volutpat volutpat non ut tortor. Sed varius sem elit, a ultrices lorem dapibus sed. Proin non fringilla sapien. Ut et tellus scelerisque, rutrum felis non, tristique eros. Pellentesque nec diam semper, commodo nunc ac, pharetra urna. Sed feugiat quam vel interdum vehicula. Praesent nec iaculis magna.
    </p>
    <p>&nbsp;</p>
    <p>
        Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras consequat felis nulla, tincidunt ultricies nisi semper ut. Donec tempor tincidunt orci, sit amet facilisis sapien dapibus ut. Nulla nunc tortor, ultrices quis pellentesque vitae, fermentum vel libero. Nunc sodales nisi a turpis ultricies, vel accumsan lacus aliquam. Proin luctus nunc quis velit sodales, eu sollicitudin nulla facilisis. Praesent tempor nunc vel leo venenatis hendrerit. Donec vestibulum dui non ex blandit dictum. Fusce venenatis fringilla ante in bibendum. Integer euismod dictum dui ac feugiat.

        Ut egestas risus lacus, sit amet ultrices nibh auctor eget. In aliquet porta bibendum. In suscipit aliquet libero, sit amet pretium diam mollis quis. Etiam lacinia facilisis ex eu maximus. In sit amet lorem in mauris rhoncus consequat eget at urna. Nunc id ligula efficitur, volutpat nibh in, venenatis ex. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi quis tristique ipsum. Praesent justo risus, pulvinar nec mauris vel, varius rutrum massa. Donec luctus, sapien eu scelerisque varius, turpis odio viverra ante, et rhoncus massa nisi quis risus. Vestibulum efficitur malesuada nisl, sit amet porttitor ipsum consectetur vel.

        Nulla facilisi. Morbi eu eros tortor. Etiam vitae ex a metus sodales egestas. Integer consequat eros tortor, et molestie eros consequat et. Fusce tellus tellus, varius sit amet purus et, mattis aliquam nulla. Curabitur volutpat sapien vel lorem vestibulum consectetur. Vestibulum volutpat sit amet nunc ac maximus. Etiam rutrum nisi ac orci congue, vitae venenatis est dapibus. Aliquam erat volutpat. Donec dictum commodo dolor at dignissim. Morbi eget lorem sagittis, vestibulum sem ac, tristique massa.

        Nullam ornare neque eget justo dignissim pellentesque. Donec condimentum vitae felis sed dignissim. Nunc ac turpis eget velit congue suscipit eu sed elit. In interdum posuere viverra. Phasellus aliquam urna sollicitudin est sodales condimentum. Mauris sed lacus vitae mi dignissim blandit vulputate sed augue. Phasellus lacinia posuere dui eu mollis. Quisque ornare erat vitae leo malesuada dapibus. Proin interdum fringilla turpis. Ut nulla ligula, vulputate ac aliquet quis, cursus sed nibh.

        In in pulvinar urna, et pellentesque augue. Donec id consequat mauris. Praesent porttitor auctor lacus ut blandit. Nullam porta mauris eget enim ornare, quis semper risus aliquam. Duis sit amet euismod ante, vel laoreet orci. Aliquam blandit orci at dolor pretium ultricies. Vivamus a leo in sapien volutpat volutpat non ut tortor. Sed varius sem elit, a ultrices lorem dapibus sed. Proin non fringilla sapien. Ut et tellus scelerisque, rutrum felis non, tristique eros. Pellentesque nec diam semper, commodo nunc ac, pharetra urna. Sed feugiat quam vel interdum vehicula. Praesent nec iaculis magna.
    </p>
    <p>&nbsp;</p>
    <p>
        Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras consequat felis nulla, tincidunt ultricies nisi semper ut. Donec tempor tincidunt orci, sit amet facilisis sapien dapibus ut. Nulla nunc tortor, ultrices quis pellentesque vitae, fermentum vel libero. Nunc sodales nisi a turpis ultricies, vel accumsan lacus aliquam. Proin luctus nunc quis velit sodales, eu sollicitudin nulla facilisis. Praesent tempor nunc vel leo venenatis hendrerit. Donec vestibulum dui non ex blandit dictum. Fusce venenatis fringilla ante in bibendum. Integer euismod dictum dui ac feugiat.

        Ut egestas risus lacus, sit amet ultrices nibh auctor eget. In aliquet porta bibendum. In suscipit aliquet libero, sit amet pretium diam mollis quis. Etiam lacinia facilisis ex eu maximus. In sit amet lorem in mauris rhoncus consequat eget at urna. Nunc id ligula efficitur, volutpat nibh in, venenatis ex. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi quis tristique ipsum. Praesent justo risus, pulvinar nec mauris vel, varius rutrum massa. Donec luctus, sapien eu scelerisque varius, turpis odio viverra ante, et rhoncus massa nisi quis risus. Vestibulum efficitur malesuada nisl, sit amet porttitor ipsum consectetur vel.

        Nulla facilisi. Morbi eu eros tortor. Etiam vitae ex a metus sodales egestas. Integer consequat eros tortor, et molestie eros consequat et. Fusce tellus tellus, varius sit amet purus et, mattis aliquam nulla. Curabitur volutpat sapien vel lorem vestibulum consectetur. Vestibulum volutpat sit amet nunc ac maximus. Etiam rutrum nisi ac orci congue, vitae venenatis est dapibus. Aliquam erat volutpat. Donec dictum commodo dolor at dignissim. Morbi eget lorem sagittis, vestibulum sem ac, tristique massa.

        Nullam ornare neque eget justo dignissim pellentesque. Donec condimentum vitae felis sed dignissim. Nunc ac turpis eget velit congue suscipit eu sed elit. In interdum posuere viverra. Phasellus aliquam urna sollicitudin est sodales condimentum. Mauris sed lacus vitae mi dignissim blandit vulputate sed augue. Phasellus lacinia posuere dui eu mollis. Quisque ornare erat vitae leo malesuada dapibus. Proin interdum fringilla turpis. Ut nulla ligula, vulputate ac aliquet quis, cursus sed nibh.

        In in pulvinar urna, et pellentesque augue. Donec id consequat mauris. Praesent porttitor auctor lacus ut blandit. Nullam porta mauris eget enim ornare, quis semper risus aliquam. Duis sit amet euismod ante, vel laoreet orci. Aliquam blandit orci at dolor pretium ultricies. Vivamus a leo in sapien volutpat volutpat non ut tortor. Sed varius sem elit, a ultrices lorem dapibus sed. Proin non fringilla sapien. Ut et tellus scelerisque, rutrum felis non, tristique eros. Pellentesque nec diam semper, commodo nunc ac, pharetra urna. Sed feugiat quam vel interdum vehicula. Praesent nec iaculis magna.
    </p>
    <p>&nbsp;</p>
    <p>
        Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras consequat felis nulla, tincidunt ultricies nisi semper ut. Donec tempor tincidunt orci, sit amet facilisis sapien dapibus ut. Nulla nunc tortor, ultrices quis pellentesque vitae, fermentum vel libero. Nunc sodales nisi a turpis ultricies, vel accumsan lacus aliquam. Proin luctus nunc quis velit sodales, eu sollicitudin nulla facilisis. Praesent tempor nunc vel leo venenatis hendrerit. Donec vestibulum dui non ex blandit dictum. Fusce venenatis fringilla ante in bibendum. Integer euismod dictum dui ac feugiat.

        Ut egestas risus lacus, sit amet ultrices nibh auctor eget. In aliquet porta bibendum. In suscipit aliquet libero, sit amet pretium diam mollis quis. Etiam lacinia facilisis ex eu maximus. In sit amet lorem in mauris rhoncus consequat eget at urna. Nunc id ligula efficitur, volutpat nibh in, venenatis ex. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi quis tristique ipsum. Praesent justo risus, pulvinar nec mauris vel, varius rutrum massa. Donec luctus, sapien eu scelerisque varius, turpis odio viverra ante, et rhoncus massa nisi quis risus. Vestibulum efficitur malesuada nisl, sit amet porttitor ipsum consectetur vel.

        Nulla facilisi. Morbi eu eros tortor. Etiam vitae ex a metus sodales egestas. Integer consequat eros tortor, et molestie eros consequat et. Fusce tellus tellus, varius sit amet purus et, mattis aliquam nulla. Curabitur volutpat sapien vel lorem vestibulum consectetur. Vestibulum volutpat sit amet nunc ac maximus. Etiam rutrum nisi ac orci congue, vitae venenatis est dapibus. Aliquam erat volutpat. Donec dictum commodo dolor at dignissim. Morbi eget lorem sagittis, vestibulum sem ac, tristique massa.

        Nullam ornare neque eget justo dignissim pellentesque. Donec condimentum vitae felis sed dignissim. Nunc ac turpis eget velit congue suscipit eu sed elit. In interdum posuere viverra. Phasellus aliquam urna sollicitudin est sodales condimentum. Mauris sed lacus vitae mi dignissim blandit vulputate sed augue. Phasellus lacinia posuere dui eu mollis. Quisque ornare erat vitae leo malesuada dapibus. Proin interdum fringilla turpis. Ut nulla ligula, vulputate ac aliquet quis, cursus sed nibh.

        In in pulvinar urna, et pellentesque augue. Donec id consequat mauris. Praesent porttitor auctor lacus ut blandit. Nullam porta mauris eget enim ornare, quis semper risus aliquam. Duis sit amet euismod ante, vel laoreet orci. Aliquam blandit orci at dolor pretium ultricies. Vivamus a leo in sapien volutpat volutpat non ut tortor. Sed varius sem elit, a ultrices lorem dapibus sed. Proin non fringilla sapien. Ut et tellus scelerisque, rutrum felis non, tristique eros. Pellentesque nec diam semper, commodo nunc ac, pharetra urna. Sed feugiat quam vel interdum vehicula. Praesent nec iaculis magna.
    </p>
    <p>&nbsp;</p>
    <p>
        Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras consequat felis nulla, tincidunt ultricies nisi semper ut. Donec tempor tincidunt orci, sit amet facilisis sapien dapibus ut. Nulla nunc tortor, ultrices quis pellentesque vitae, fermentum vel libero. Nunc sodales nisi a turpis ultricies, vel accumsan lacus aliquam. Proin luctus nunc quis velit sodales, eu sollicitudin nulla facilisis. Praesent tempor nunc vel leo venenatis hendrerit. Donec vestibulum dui non ex blandit dictum. Fusce venenatis fringilla ante in bibendum. Integer euismod dictum dui ac feugiat.

        Ut egestas risus lacus, sit amet ultrices nibh auctor eget. In aliquet porta bibendum. In suscipit aliquet libero, sit amet pretium diam mollis quis. Etiam lacinia facilisis ex eu maximus. In sit amet lorem in mauris rhoncus consequat eget at urna. Nunc id ligula efficitur, volutpat nibh in, venenatis ex. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi quis tristique ipsum. Praesent justo risus, pulvinar nec mauris vel, varius rutrum massa. Donec luctus, sapien eu scelerisque varius, turpis odio viverra ante, et rhoncus massa nisi quis risus. Vestibulum efficitur malesuada nisl, sit amet porttitor ipsum consectetur vel.

        Nulla facilisi. Morbi eu eros tortor. Etiam vitae ex a metus sodales egestas. Integer consequat eros tortor, et molestie eros consequat et. Fusce tellus tellus, varius sit amet purus et, mattis aliquam nulla. Curabitur volutpat sapien vel lorem vestibulum consectetur. Vestibulum volutpat sit amet nunc ac maximus. Etiam rutrum nisi ac orci congue, vitae venenatis est dapibus. Aliquam erat volutpat. Donec dictum commodo dolor at dignissim. Morbi eget lorem sagittis, vestibulum sem ac, tristique massa.

        Nullam ornare neque eget justo dignissim pellentesque. Donec condimentum vitae felis sed dignissim. Nunc ac turpis eget velit congue suscipit eu sed elit. In interdum posuere viverra. Phasellus aliquam urna sollicitudin est sodales condimentum. Mauris sed lacus vitae mi dignissim blandit vulputate sed augue. Phasellus lacinia posuere dui eu mollis. Quisque ornare erat vitae leo malesuada dapibus. Proin interdum fringilla turpis. Ut nulla ligula, vulputate ac aliquet quis, cursus sed nibh.

        In in pulvinar urna, et pellentesque augue. Donec id consequat mauris. Praesent porttitor auctor lacus ut blandit. Nullam porta mauris eget enim ornare, quis semper risus aliquam. Duis sit amet euismod ante, vel laoreet orci. Aliquam blandit orci at dolor pretium ultricies. Vivamus a leo in sapien volutpat volutpat non ut tortor. Sed varius sem elit, a ultrices lorem dapibus sed. Proin non fringilla sapien. Ut et tellus scelerisque, rutrum felis non, tristique eros. Pellentesque nec diam semper, commodo nunc ac, pharetra urna. Sed feugiat quam vel interdum vehicula. Praesent nec iaculis magna.
    </p>

    <p>
        Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras consequat felis nulla, tincidunt ultricies nisi semper ut. Donec tempor tincidunt orci, sit amet facilisis sapien dapibus ut. Nulla nunc tortor, ultrices quis pellentesque vitae, fermentum vel libero. Nunc sodales nisi a turpis ultricies, vel accumsan lacus aliquam. Proin luctus nunc quis velit sodales, eu sollicitudin nulla facilisis. Praesent tempor nunc vel leo venenatis hendrerit. Donec vestibulum dui non ex blandit dictum. Fusce venenatis fringilla ante in bibendum. Integer euismod dictum dui ac feugiat.

        Ut egestas risus lacus, sit amet ultrices nibh auctor eget. In aliquet porta bibendum. In suscipit aliquet libero, sit amet pretium diam mollis quis. Etiam lacinia facilisis ex eu maximus. In sit amet lorem in mauris rhoncus consequat eget at urna. Nunc id ligula efficitur, volutpat nibh in, venenatis ex. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi quis tristique ipsum. Praesent justo risus, pulvinar nec mauris vel, varius rutrum massa. Donec luctus, sapien eu scelerisque varius, turpis odio viverra ante, et rhoncus massa nisi quis risus. Vestibulum efficitur malesuada nisl, sit amet porttitor ipsum consectetur vel.

        Nulla facilisi. Morbi eu eros tortor. Etiam vitae ex a metus sodales egestas. Integer consequat eros tortor, et molestie eros consequat et. Fusce tellus tellus, varius sit amet purus et, mattis aliquam nulla. Curabitur volutpat sapien vel lorem vestibulum consectetur. Vestibulum volutpat sit amet nunc ac maximus. Etiam rutrum nisi ac orci congue, vitae venenatis est dapibus. Aliquam erat volutpat. Donec dictum commodo dolor at dignissim. Morbi eget lorem sagittis, vestibulum sem ac, tristique massa.

        Nullam ornare neque eget justo dignissim pellentesque. Donec condimentum vitae felis sed dignissim. Nunc ac turpis eget velit congue suscipit eu sed elit. In interdum posuere viverra. Phasellus aliquam urna sollicitudin est sodales condimentum. Mauris sed lacus vitae mi dignissim blandit vulputate sed augue. Phasellus lacinia posuere dui eu mollis. Quisque ornare erat vitae leo malesuada dapibus. Proin interdum fringilla turpis. Ut nulla ligula, vulputate ac aliquet quis, cursus sed nibh.

        In in pulvinar urna, et pellentesque augue. Donec id consequat mauris. Praesent porttitor auctor lacus ut blandit. Nullam porta mauris eget enim ornare, quis semper risus aliquam. Duis sit amet euismod ante, vel laoreet orci. Aliquam blandit orci at dolor pretium ultricies. Vivamus a leo in sapien volutpat volutpat non ut tortor. Sed varius sem elit, a ultrices lorem dapibus sed. Proin non fringilla sapien. Ut et tellus scelerisque, rutrum felis non, tristique eros. Pellentesque nec diam semper, commodo nunc ac, pharetra urna. Sed feugiat quam vel interdum vehicula. Praesent nec iaculis magna.
    </p>
    <p>
        Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras consequat felis nulla, tincidunt ultricies nisi semper ut. Donec tempor tincidunt orci, sit amet facilisis sapien dapibus ut. Nulla nunc tortor, ultrices quis pellentesque vitae, fermentum vel libero. Nunc sodales nisi a turpis ultricies, vel accumsan lacus aliquam. Proin luctus nunc quis velit sodales, eu sollicitudin nulla facilisis. Praesent tempor nunc vel leo venenatis hendrerit. Donec vestibulum dui non ex blandit dictum. Fusce venenatis fringilla ante in bibendum. Integer euismod dictum dui ac feugiat.

        Ut egestas risus lacus, sit amet ultrices nibh auctor eget. In aliquet porta bibendum. In suscipit aliquet libero, sit amet pretium diam mollis quis. Etiam lacinia facilisis ex eu maximus. In sit amet lorem in mauris rhoncus consequat eget at urna. Nunc id ligula efficitur, volutpat nibh in, venenatis ex. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi quis tristique ipsum. Praesent justo risus, pulvinar nec mauris vel, varius rutrum massa. Donec luctus, sapien eu scelerisque varius, turpis odio viverra ante, et rhoncus massa nisi quis risus. Vestibulum efficitur malesuada nisl, sit amet porttitor ipsum consectetur vel.

        Nulla facilisi. Morbi eu eros tortor. Etiam vitae ex a metus sodales egestas. Integer consequat eros tortor, et molestie eros consequat et. Fusce tellus tellus, varius sit amet purus et, mattis aliquam nulla. Curabitur volutpat sapien vel lorem vestibulum consectetur. Vestibulum volutpat sit amet nunc ac maximus. Etiam rutrum nisi ac orci congue, vitae venenatis est dapibus. Aliquam erat volutpat. Donec dictum commodo dolor at dignissim. Morbi eget lorem sagittis, vestibulum sem ac, tristique massa.

        Nullam ornare neque eget justo dignissim pellentesque. Donec condimentum vitae felis sed dignissim. Nunc ac turpis eget velit congue suscipit eu sed elit. In interdum posuere viverra. Phasellus aliquam urna sollicitudin est sodales condimentum. Mauris sed lacus vitae mi dignissim blandit vulputate sed augue. Phasellus lacinia posuere dui eu mollis. Quisque ornare erat vitae leo malesuada dapibus. Proin interdum fringilla turpis. Ut nulla ligula, vulputate ac aliquet quis, cursus sed nibh.

        In in pulvinar urna, et pellentesque augue. Donec id consequat mauris. Praesent porttitor auctor lacus ut blandit. Nullam porta mauris eget enim ornare, quis semper risus aliquam. Duis sit amet euismod ante, vel laoreet orci. Aliquam blandit orci at dolor pretium ultricies. Vivamus a leo in sapien volutpat volutpat non ut tortor. Sed varius sem elit, a ultrices lorem dapibus sed. Proin non fringilla sapien. Ut et tellus scelerisque, rutrum felis non, tristique eros. Pellentesque nec diam semper, commodo nunc ac, pharetra urna. Sed feugiat quam vel interdum vehicula. Praesent nec iaculis magna.
    </p>

    <p>
        Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras consequat felis nulla, tincidunt ultricies nisi semper ut. Donec tempor tincidunt orci, sit amet facilisis sapien dapibus ut. Nulla nunc tortor, ultrices quis pellentesque vitae, fermentum vel libero. Nunc sodales nisi a turpis ultricies, vel accumsan lacus aliquam. Proin luctus nunc quis velit sodales, eu sollicitudin nulla facilisis. Praesent tempor nunc vel leo venenatis hendrerit. Donec vestibulum dui non ex blandit dictum. Fusce venenatis fringilla ante in bibendum. Integer euismod dictum dui ac feugiat.

        Ut egestas risus lacus, sit amet ultrices nibh auctor eget. In aliquet porta bibendum. In suscipit aliquet libero, sit amet pretium diam mollis quis. Etiam lacinia facilisis ex eu maximus. In sit amet lorem in mauris rhoncus consequat eget at urna. Nunc id ligula efficitur, volutpat nibh in, venenatis ex. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi quis tristique ipsum. Praesent justo risus, pulvinar nec mauris vel, varius rutrum massa. Donec luctus, sapien eu scelerisque varius, turpis odio viverra ante, et rhoncus massa nisi quis risus. Vestibulum efficitur malesuada nisl, sit amet porttitor ipsum consectetur vel.

        Nulla facilisi. Morbi eu eros tortor. Etiam vitae ex a metus sodales egestas. Integer consequat eros tortor, et molestie eros consequat et. Fusce tellus tellus, varius sit amet purus et, mattis aliquam nulla. Curabitur volutpat sapien vel lorem vestibulum consectetur. Vestibulum volutpat sit amet nunc ac maximus. Etiam rutrum nisi ac orci congue, vitae venenatis est dapibus. Aliquam erat volutpat. Donec dictum commodo dolor at dignissim. Morbi eget lorem sagittis, vestibulum sem ac, tristique massa.

        Nullam ornare neque eget justo dignissim pellentesque. Donec condimentum vitae felis sed dignissim. Nunc ac turpis eget velit congue suscipit eu sed elit. In interdum posuere viverra. Phasellus aliquam urna sollicitudin est sodales condimentum. Mauris sed lacus vitae mi dignissim blandit vulputate sed augue. Phasellus lacinia posuere dui eu mollis. Quisque ornare erat vitae leo malesuada dapibus. Proin interdum fringilla turpis. Ut nulla ligula, vulputate ac aliquet quis, cursus sed nibh.

        In in pulvinar urna, et pellentesque augue. Donec id consequat mauris. Praesent porttitor auctor lacus ut blandit. Nullam porta mauris eget enim ornare, quis semper risus aliquam. Duis sit amet euismod ante, vel laoreet orci. Aliquam blandit orci at dolor pretium ultricies. Vivamus a leo in sapien volutpat volutpat non ut tortor. Sed varius sem elit, a ultrices lorem dapibus sed. Proin non fringilla sapien. Ut et tellus scelerisque, rutrum felis non, tristique eros. Pellentesque nec diam semper, commodo nunc ac, pharetra urna. Sed feugiat quam vel interdum vehicula. Praesent nec iaculis magna.
    </p>
    <p>last line</p>

    <fastpath-chat
        hosted="<%= url %>/webchat"
        domain="<%= domain %>"
        server="<%= host %>"
        workgroup="demo">
    </fastpath-chat>
    <script src="<%= url %>/webchat/ofmeet.js"></script>
</body>
</html>