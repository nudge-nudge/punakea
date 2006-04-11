#import "PAResultsOutlineView.h"

@implementation PAResultsOutlineView

#pragma mark Init
- (void)awakeFromNib
{
	[self setIndentationPerLevel:0.0];
	[self setIntercellSpacing:NSMakeSize(0,1)];
	[[self delegate] setOutlineView:self];
	
	userDefaultsFile = @"Results.plist";
	[self loadUserDefaults];
}


#pragma mark Instance Methods
- (NSRect)frameOfCellAtColumn:(int)columnIndex row:(int)rowIndex
{
	/*if([self levelForRow:rowIndex] == 0)
	{
		// Ignore intercell spacing for group cells
		NSRect rect = [super frameOfCellAtColumn:columnIndex row:rowIndex];
		NSSize intercellSpacing = [self intercellSpacing];
		
		rect.origin.x = rect.origin.x - intercellSpacing.width;
		rect.origin.y = rect.origin.y - intercellSpacing.height;
		rect.size.width = rect.size.width + 2 * intercellSpacing.width;
		rect.size.height = rect.size.height + intercellSpacing.height;
		
		return rect;
	}*/
	
	return [super frameOfCellAtColumn:columnIndex row:rowIndex];
}


#pragma mark Actions
- (void)reloadData
{
    while ([[self subviews] count] > 0)
    {
		[[[self subviews] lastObject] removeFromSuperviewWithoutNeedingDisplay];
    }
    
    [super reloadData];
}

- (void)loadUserDefaults
{
	// Create preferences folder if it doesn't exists yet
	NSFileManager *fileManager = [NSFileManager defaultManager]; 
	NSString *folder = @"~/Library/Application Support/Punakea/"; 
	folder = [folder stringByExpandingTildeInPath]; 
	
	if (![fileManager fileExistsAtPath: folder]) 
		[fileManager createDirectoryAtPath: folder attributes: nil];
	
	NSString *fileName = [folder stringByAppendingPathComponent:userDefaultsFile]; 
	
	// If no plist exists, use the default one from Resources bundle
	if(![fileManager fileExistsAtPath:fileName])
	{
		NSBundle *bundle = [NSBundle mainBundle];
		NSString *path = [bundle pathForResource:@"Results" ofType:@"plist"];
		userDefaults = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
	} else {
		userDefaults = [[NSMutableDictionary alloc] initWithContentsOfFile:fileName];
	}
}

- (void)saveUserDefaults
{
	NSString *folder = @"~/Library/Application Support/Punakea/"; 
	folder = [folder stringByExpandingTildeInPath]; 
	
	NSString *fileName = [folder stringByAppendingPathComponent:userDefaultsFile]; 
	[userDefaults writeToFile:fileName atomically:YES];
}


#pragma mark Notifications
- (void)queryNote:(NSNotification *)note
{	
	if ([[note name] isEqualToString:NSMetadataQueryGatheringProgressNotification] ||
		[[note name] isEqualToString:NSMetadataQueryDidUpdateNotification] ||
		[[note name] isEqualToString:NSMetadataQueryDidFinishGatheringNotification])
	{
		[self reloadData];
		
		int i;
		for(i = 0; i < [self numberOfRows]; i++)
		{
			if([self levelForRow:i] == 0) [self expandItem:[self itemAtRow:i]];
		}
	}
}


#pragma mark Accessors
- (NSMetadataQuery *)query
{
	return query;
}

- (void)setQuery:(NSMetadataQuery *)aQuery
{
	query = aQuery;
	NSNotificationCenter *nf = [NSNotificationCenter defaultCenter];
    [nf addObserver:self selector:@selector(queryNote:) name:nil object:query];
	[[self delegate] setQuery:query];
}

- (NSMutableDictionary *)userDefaults
{
	return userDefaults;
}

- (NSString *)userDefaultsFile
{
	return userDefaultsFile;
}

@end
