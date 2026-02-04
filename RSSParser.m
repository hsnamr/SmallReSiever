//
//  RSSParser.m
//  SmallReSiever
//
//  RSS/Atom parsing via libxml2 (FOSS).
//

#import "RSSParser.h"
#import "RSSFeed.h"
#import "RSSItem.h"
#import <libxml/parser.h>
#import <libxml/tree.h>

@implementation RSSParser

static NSString *strFromXmlChar(const xmlChar *x) {
    if (!x) return @"";
    return [NSString stringWithUTF8String:(const char *)x];
}

static const char *localName(xmlNode *node) {
    if (!node || !node->name) return "";
    const char *name = (const char *)node->name;
    const char *colon = strchr(name, ':');
    return colon ? colon + 1 : name;
}

static void appendTextFromNode(xmlNode *node, NSMutableString *out) {
    if (!node || !out) return;
    if (node->type == XML_TEXT_NODE && node->content) {
        [out appendString:strFromXmlChar(node->content)];
        return;
    }
    if (node->type == XML_CDATA_SECTION_NODE && node->content) {
        [out appendString:strFromXmlChar(node->content)];
        return;
    }
    for (xmlNode *c = node->children; c; c = c->next)
        appendTextFromNode(c, out);
}

static NSString *contentOfElement(xmlNode *node) {
    if (!node) return @"";
    NSMutableString *acc = [NSMutableString string];
    appendTextFromNode(node, acc);
    return [acc stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

static NSString *contentOrFirstChild(xmlNode *parent, const char *name) {
    for (xmlNode *n = parent->children; n; n = n->next) {
        if (n->type == XML_ELEMENT_NODE && xmlStrcmp(n->name, (const xmlChar *)name) == 0)
            return [contentOfElement(n) stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    return @"";
}

static NSString *contentOrFirstChildNS(xmlNode *parent, const char *localName, const char *nsHref) {
    for (xmlNode *n = parent->children; n; n = n->next) {
        if (n->type != XML_ELEMENT_NODE) continue;
        const char *local = (const char *)(n->name);
        if (strchr((const char *)n->name, ':')) local = strchr((const char *)n->name, ':') + 1;
        if (nsHref && n->ns && n->ns->href && xmlStrcmp(n->ns->href, (const xmlChar *)nsHref) != 0) continue;
        if (strcmp(local, localName) == 0)
            return [contentOfElement(n) stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    return @"";
}

static NSString *hrefFromLink(xmlNode *itemOrEntry) {
    for (xmlNode *n = itemOrEntry->children; n; n = n->next) {
        if (n->type != XML_ELEMENT_NODE) continue;
        const char *local = (const char *)n->name;
        if (strchr((const char *)n->name, ':')) local = strchr((const char *)n->name, ':') + 1;
        if (strcmp(local, "link") != 0) continue;
        xmlChar *rel = xmlGetProp(n, (const xmlChar *)"rel");
        if (rel && xmlStrcmp(rel, (const xmlChar *)"enclosure") == 0) { xmlFree(rel); continue; }
        if (rel) xmlFree(rel);
        xmlChar *href = xmlGetProp(n, (const xmlChar *)"href");
        if (href) {
            NSString *s = strFromXmlChar(href);
            xmlFree(href);
            return s;
        }
        return contentOfElement(n);
    }
    return @"";
}

static NSDate *dateFromString(NSString *s) {
    if (!s || s.length == 0) return nil;
    NSArray *formats = [NSArray arrayWithObjects:
        @"yyyy-MM-dd'T'HH:mm:ssZ",
        @"yyyy-MM-dd'T'HH:mm:ss.SSSZ",
        @"EEE, dd MMM yyyy HH:mm:ss Z",
        @"EEE, dd MMM yyyy HH:mm Z",
        @"dd MMM yyyy HH:mm:ss Z",
        @"yyyy-MM-dd HH:mm:ssZ",
        @"yyyy-MM-dd",
        nil];
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    [f setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    for (NSString *fmt in formats) {
        [f setDateFormat:fmt];
        NSDate *d = [f dateFromString:s];
        if (d) {
#if defined(GNUSTEP) && !__has_feature(objc_arc)
            [f release];
#endif
            return d;
        }
    }
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    [f release];
#endif
    return nil;
}

+ (RSSFeed *)feedFromData:(NSData *)data feedURL:(NSString *)feedURL {
    if (!data || data.length == 0) return nil;

    const char *bytes = (const char *)[data bytes];
    int len = (int)[data length];
    xmlDoc *doc = xmlReadMemory(bytes, len, NULL, NULL, XML_PARSE_NOERROR | XML_PARSE_NOWARNING);
    if (!doc) return nil;

    RSSFeed *feed = [[RSSFeed alloc] init];
    [feed setFeedURL:feedURL];
    NSMutableArray *items = [NSMutableArray array];

    xmlNode *root = xmlDocGetRootElement(doc);
    if (!root) { xmlFreeDoc(doc); return [feed autorelease]; }

    // RSS 2.0: rss -> channel
    if (xmlStrcmp(root->name, (const xmlChar *)"rss") == 0) {
        xmlNode *channel = NULL;
        for (xmlNode *n = root->children; n; n = n->next)
            if (n->type == XML_ELEMENT_NODE && xmlStrcmp(n->name, (const xmlChar *)"channel") == 0) { channel = n; break; }
        if (channel) {
            [feed setTitle:contentOrFirstChild(channel, "title")];
            [feed setLink:contentOrFirstChild(channel, "link")];
            for (xmlNode *item = channel->children; item; item = item->next) {
                if (item->type != XML_ELEMENT_NODE || xmlStrcmp(item->name, (const xmlChar *)"item") != 0) continue;
                RSSItem *entry = [[RSSItem alloc] init];
                [entry setTitle:contentOrFirstChild(item, "title")];
                [entry setLink:contentOrFirstChild(item, "link")];
                [entry setItemDescription:contentOrFirstChild(item, "description")];
                [entry setContent:contentOrFirstChild(item, "description")];
                NSString *pub = contentOrFirstChild(item, "pubDate");
                if (pub.length) [entry setDate:dateFromString(pub)];
                [items addObject:entry];
#if defined(GNUSTEP) && !__has_feature(objc_arc)
                [entry release];
#endif
            }
        }
    }
    // Atom: feed -> entry (local name "feed")
    else if (strcmp(localName(root), "feed") == 0) {
        [feed setTitle:contentOrFirstChildNS(root, "title", "http://www.w3.org/2005/Atom")];
        [feed setLink:hrefFromLink(root)];
        for (xmlNode *n = root->children; n; n = n->next) {
            if (n->type != XML_ELEMENT_NODE) continue;
            const char *local = (const char *)n->name;
            if (strchr((const char *)n->name, ':')) local = strchr((const char *)n->name, ':') + 1;
            if (strcmp(local, "entry") != 0) continue;

            RSSItem *entry = [[RSSItem alloc] init];
            [entry setTitle:contentOrFirstChildNS(n, "title", "http://www.w3.org/2005/Atom")];
            [entry setLink:hrefFromLink(n)];
            NSString *summary = contentOrFirstChildNS(n, "summary", "http://www.w3.org/2005/Atom");
            NSString *content = contentOrFirstChildNS(n, "content", "http://www.w3.org/2005/Atom");
            [entry setItemDescription:summary];
            [entry setContent:(content.length ? content : summary)];
            NSString *updated = contentOrFirstChildNS(n, "updated", "http://www.w3.org/2005/Atom");
            if (updated.length) [entry setDate:dateFromString(updated)];
            NSString *idStr = contentOrFirstChildNS(n, "id", "http://www.w3.org/2005/Atom");
            if (idStr.length) [entry setIdentifier:idStr];
            [items addObject:entry];
#if defined(GNUSTEP) && !__has_feature(objc_arc)
            [entry release];
#endif
        }
    }

    [feed setItems:items];
    xmlFreeDoc(doc);

#if defined(GNUSTEP) && !__has_feature(objc_arc)
    return [feed autorelease];
#else
    return feed;
#endif
}

@end
